#include <stdlib.h>
#include <math.h>
#include "pb_render.h"
#include <stdio.h>

static int vigRampSet = 0;
static unsigned char vigRamp[65536];
static double cvRgb[256];
static double sqrRgb[256];	
static unsigned char scurveRGB[256];
static unsigned char gammaRGB[256];
static unsigned char  colorFadeB[256];
static unsigned char  colorFadeG[256];
static unsigned char  colorFadeR[256];
static unsigned char  colorClipB[256];
static unsigned char  colorClipG[256];
static unsigned char  colorClipR[256];
static unsigned char  diffuse[256][256];
static unsigned char  cornersoft[256][256];
static unsigned char  mult[256][256];
static double rr,gg,bb2;


unsigned char calculateSquareVignetteValue( int _width, int _height, int cornerLength, int offsetX, int offsetY, int x, int y )
{
	if (vigRampSet == 0)
	{
		int tempInt;
		double contrast = 2.0f;
		double pivot = 0.5f;
		for (int i=0; i< 65536; i++)
		{
			if(i>=32768)
			{
				tempInt = 65535 * pow((i - 65535)/(pivot*65535 - 65535),contrast) * (pivot - 1.0f) + 65535;
			}
			else 
			{
				tempInt = 65535 *pow(i/(pivot*65535),contrast) * pivot;
			}
			if (tempInt<0) vigRamp[i]= 255;
			else if (tempInt>65535) vigRamp[i] = 0;
			else vigRamp[i] = 255 - tempInt / 256;

			//vigRamp[i] = floor( 255 * ((double) (65535.0 - i) / 65535.0) );
		}
		vigRampSet = 1;
	}
	
	int posX = offsetX + x;
	int posY = offsetY + y;
	
	// PosVal: is devided into 9 area (3x3)... from top down left to right... 
	//    2, 1, 3
	//    8, 7, 9
	//    5, 4, 6
	//
	int posVal = 0;
	if ( posY < cornerLength )
	{
		posVal = 1;
	} 
	else if ( posY > (_height - cornerLength) )
	{
		posVal = 4;
	}
	else {
		posVal = 7;
	}
	
	if (posX < cornerLength )
	{
		posVal++;
	}
	else if (posX > (_width - cornerLength) )
	{
		posVal += 2;
	}

	double dX, dY;
	int idx;
	switch (posVal)
	{
		case 1:
			// Top center
			idx = (int) floor( (65535.0 *  (cornerLength - posY)) / cornerLength);
			return vigRamp[idx]; 
			break;
		case 2:
			// Top Left Corner
			//
			dX = (double) (cornerLength - posX) / cornerLength;
			dY = (double) (cornerLength - posY) / cornerLength;
			dX = sqrt(dX*dX+dY*dY);
			if (dX > 1.0)
				dX = 1.0;
			idx = (int) 65535 * dX;
			return vigRamp[idx];
			break;
		case 3:
			// Top Right Corner
			//
			dX = (double) (cornerLength - (_width - posX)) / cornerLength;
		    dY = (double) (cornerLength - posY) / cornerLength;
			dX = sqrt(dX*dX+dY*dY);
			if (dX > 1.0)
				dX = 1.0;
			idx = (int) 65535 * dX;
			return vigRamp[idx];
			break;
		case 4:
			// Bottom center
			idx = (int) floor( (65535.0 *  (cornerLength - (_height - posY))) / cornerLength);
			return vigRamp[idx]; 
			break;
		case 5:
			// Bottom Left Corner
			//
			dX = (double) (cornerLength - posX) / cornerLength;
			dY = (double) (cornerLength - (_height - posY)) / cornerLength;
			dX = sqrt(dX*dX+dY*dY);
			if (dX > 1.0)
				dX = 1.0;
			idx = (int) 65535 * dX;
			return vigRamp[idx];
			break;
		case 6:
			// Bottom Right Corner
			//
			dX = (double) (cornerLength - (_width - posX)) / cornerLength;
			dY = (double) (cornerLength - (_height - posY)) / cornerLength;
			dX = sqrt(dX*dX+dY*dY);
			if (dX > 1.0)
			   dX = 1.0;
			idx = (int) 65535 * dX;
			return vigRamp[idx];
			break;
		case 7:
			// center of the vignette, all transparent
			return vigRamp[0];
			break;
		case 8:
			// Left center
			idx = (int) floor( (65535.0 *  (cornerLength - posX)) / cornerLength);
			return vigRamp[idx]; 
			break;
		case 9:
			// Right center
			idx = (int) floor( (65535.0 *  (cornerLength - (_width - posX))) / cornerLength);
			return vigRamp[idx]; 
			break;
		default:
			return vigRamp[65535];
			break;
	}
}

#define CV_FALLOFF (2.0)
#define	CV_ZOOMOFF (0.5)
unsigned char calculateCircleVignetteValue( int _width, int _height, int x, int y )
{
	int isLandscape = _width>_height;
	int center = isLandscape? (_width>>1) : (_height>>1) ;
	double aspect_ratio = isLandscape? (1.0 * _width / _height) : (1.0 * _height / _width);	
	double invertCenter = 1.0 / center;

	double xf = x * invertCenter;
	double yf = y * invertCenter;	
	if (isLandscape)
		yf *= aspect_ratio;
	else
		xf *= aspect_ratio;

	double deltaY = CV_ZOOMOFF * (yf - 1.0);
	double deltaX = CV_ZOOMOFF * (xf - 1.0);
	if (isLandscape)
		deltaY /= aspect_ratio;
	else
		deltaX /= aspect_ratio;

	double value = 1.0 - sqrt(deltaY*deltaY+deltaX*deltaX);	
	if(value<=0.0f)
		value = 0.0;
	
	value = pow(value, CV_FALLOFF - value * CV_FALLOFF);
	return (unsigned char) floor(value*255);
}

// This prepares look up tables for the effects below, so you can just plug them in.
void pb_Prep_LUT( ffRGBMaxMin3D _CCrgbMaxMin, ffColor3D _monorgb, ffRGBMaxMin3D _colorFadergbMaxMin, double cornerOpacity, double sCcontrast, double cvOpacity, double SqrOpacity, double diffOpacity, double gammaCorrection )
{
	//colorClip - paramters
	//  f(x)=kx+b
	double rk,rb,gk,gb,bk,bb;
	rk = 1.0f / (_CCrgbMaxMin.rMax - _CCrgbMaxMin.rMin);
	rb = -_CCrgbMaxMin.rMin * rk;
	gk = 1.0f / (_CCrgbMaxMin.gMax - _CCrgbMaxMin.gMin);
	gb = -_CCrgbMaxMin.gMin * gk;
	bk = 1.0f / (_CCrgbMaxMin.bMax - _CCrgbMaxMin.bMin);
	bb = -_CCrgbMaxMin.bMin * bk;
	
	//monoChrome - parameters
	//
	double rRand,gRand,bRand,average;	
	rRand = _monorgb.r;
	gRand = _monorgb.g;
	bRand = _monorgb.b;	
	average = rRand + gRand + bRand;	
	rr = rRand / average;
	gg = gRand / average;
	bb2 = bRand / average;
	
	//sCurve - paramters
	//
	double pivot = 0.5f;
	
	//colorfade - paramters;
	//  f(x) = opk * x + bop;
	double rminop,gminop,bminop;
	double rmaxop,gmaxop,bmaxop;
	double ropk,ropb,gopk,gopb,bopk,bopb;
	rminop = _colorFadergbMaxMin.rMin;
	rmaxop = _colorFadergbMaxMin.rMax;
	ropb = rminop;
	ropk = rmaxop - rminop;
	gminop = _colorFadergbMaxMin.gMin;
	gmaxop = _colorFadergbMaxMin.gMax;	
	gopb = gminop;
	gopk = gmaxop - gminop;
	bminop = _colorFadergbMaxMin.bMin;
	bmaxop = _colorFadergbMaxMin.bMax;
	bopb = bminop;
	bopk = bmaxop - bminop;
	
	
	// preparation of LUTs for some selected process
	//
	double inversecornerOpacity = (1.0f - cornerOpacity);
	int tempInt;
	for(int i=0;i<256;i++)
	{
		if(i>=(pivot*255))
		{
			tempInt = 255 * pow((i - 255)/(pivot*255 - 255),sCcontrast) * (pivot - 1.0f) + 255;
		}
		else 
		{
			tempInt = 255 *pow(i/(pivot*255),sCcontrast) * pivot;
		}
		if (tempInt<0) scurveRGB[i]=0;
		else if (tempInt>255) scurveRGB[i] = 255;
		else scurveRGB[i] = tempInt;
		
		//colorFade
		tempInt = i * bopk + bopb*255;
		if (tempInt<0) colorFadeB[i]=0;
		else if (tempInt>255) colorFadeB[i] = 255;
		else colorFadeB[i] = tempInt;
		
		tempInt = i * gopk + gopb*255;
		if (tempInt<0) colorFadeG[i]=0;
		else if (tempInt>255) colorFadeG[i] = 255;
		else colorFadeG[i] = tempInt;
		
		tempInt = i * ropk + ropb*255;
		if (tempInt<0) colorFadeR[i]=0;
		else if (tempInt>255) colorFadeR[i] = 255;
		else colorFadeR[i] = tempInt;
		
		//colorClip
		tempInt = i * bk + bb*255;
		if (tempInt<0) colorClipB[i]=0;
		else if (tempInt>255) colorClipB[i] = 255;
		else colorClipB[i] = tempInt;
		
		tempInt = i * gk + gb*255;
		if (tempInt<0) colorClipG[i]=0;
		else if (tempInt>255) colorClipG[i] = 255;
		else colorClipG[i] = tempInt;
		
		tempInt = i * rk + rb*255;
		if (tempInt<0) colorClipR[i]=0;
		else if (tempInt>255) colorClipR[i] = 255;
		else colorClipR[i] = tempInt;
		
		//circleVignette
		cvRgb[i] = (1.0f - cvOpacity * (255 - i)/255.0f );
		
		//sqrVignette
		sqrRgb[i] = (1.0f - SqrOpacity * (255 - i)/255.0f );
        
        // gamma : http://www.dfstudios.co.uk/articles/programming/image-programming-algorithms/image-processing-algorithms-part-6-gamma-correction/
        gammaRGB[i] = (int) round(255.0 * pow((double)i / 255.0, gammaCorrection));
		
		for (int j=0; j<256; j++)
		{
			cornersoft[i][j] = (i * cornerOpacity + j * inversecornerOpacity);
			diffuse[i][j] = 255 - (255 - j * diffOpacity) * (255 - i)/255;
			mult[i][j] = i * j/255;
		}
	}
}	

// tile rendering requiring the LUT to be prepared before tile rendering
// Without doing this, the tile_rendering will be garbage
//
#define RANDDOM_NOISE ((int)(arc4random() % 7) - 3)
unsigned char *pb_tile_render(
						 int _width, int _height, int _offset_height, int _img_height, int randNum,
						 unsigned char *m_cvdata, unsigned char *m_vigdata, unsigned char *m_softdata, unsigned char *m_sourcedata, unsigned char *m_leakdata, unsigned char *m_borderdata,
						 double blendrand, double _sqrX, double _sqrY, void* context, int(*progressCallback)(double completion, void* context)
						 )
{
	if (!m_sourcedata || !m_softdata)
		return NULL;
	
 	//Progress
	//
	float completion = 0.3+0.7*_offset_height/_img_height;
	float step = 0.7/_img_height;
//	if ( progressCallback )
//	{
//		if ( progressCallback(completion) )
//		{
//			return NULL;
//		}
//	}
	
    // Resulting output buffer
	//
	unsigned char *pout, *poutb;
	pout = poutb = (unsigned char *)malloc(_width * _height * 4);
    if (!pout)
	{
		return NULL;
	}
	
	// pixel loop for rendering
	//
    int x, y;    
    int r,g,b;
	//unsigned char *cvb;
	//int halfWidth = (_width/2.0f+0.5f);
	//int halfHeight = (_img_height/2.0f+0.5f);
	int ccr, ccg, ccb;
	
	double cvf;
	int cv, icv;
	//int cvPos;
	int tempblendrand;
	double inverseblendrand = 1.0f - blendrand;
	int doDeSat = (randNum>=20);
	
	register unsigned char *vigb = NULL;
	register unsigned char *softb = NULL;
	register unsigned char *sourceb = NULL;
	register unsigned char *borderb = NULL;
	register unsigned char *lppb = NULL;
	
	vigb = m_vigdata ? (unsigned char *)&m_vigdata[0] : NULL;
	softb = m_softdata ? (unsigned char *)&m_softdata[0] : NULL;
	sourceb = m_sourcedata ? (unsigned char *)&m_sourcedata[0] : NULL;
	borderb = m_borderdata ? (unsigned char *)&m_borderdata[0] : NULL;
	lppb = m_leakdata ? (unsigned char *)&m_leakdata[0] : NULL;
	
	unsigned char sqrVig;
	double fSqrRgb;
	
	// Square Vignette offset calculation
	//
	int _sqrV_width = _width + (_width>>2);
	int _sqrV_height = _img_height + (_img_height>>2);
	int _sqrV_cornerLength = ( _sqrV_width > _sqrV_height ) ? _sqrV_height >> 2 : _sqrV_width >> 2;		// corner length of shorter side	
	int _sqrV_offsetX = ((int) (_width>>2) * _sqrX);
	int _sqrV_offsetY = ((int) (_img_height>>2) * _sqrY);
	
    for (y = 0; y < _height; y++) 
	{  
		//Progress
		if ( progressCallback )
		{
			if( !((y+_offset_height)%400)){
				//completion += 400*step;
				
				if(y+_offset_height == _img_height-1)
				{
					completion = 1.0;
				}
				else 
				{
					completion = 0.3+(y+_offset_height)*step;
				}

				if ( progressCallback(completion, context) )
				{
					free(poutb);
					return NULL;
				}
			}
		}
		
        for (x = 0; x < _width; x++) 
		{       
			//circleVignette
			//			if(y<halfHeight)
			//			{
			//				if(x<halfWidth)
			//				{
			//					cvPos = (x + y * halfWidth) *4;
			//				}
			//				else
			//				{
			//					cvPos = (_width - x -1 + y * halfWidth) *4;
			//				}
			//			}
			//			else
			//			{
			//				if(x<halfWidth)
			//				{
			//					cvPos = (x+ (2*halfHeight - y-1) * halfWidth) *4;
			//				}
			//				else
			//				{
			//					cvPos = (_width - x-1 + (2*halfHeight - y-1) * halfWidth) *4 ;
			//				}
			//			}
			//			cvb = (unsigned char *)&m_cvdata[cvPos];
			
			//cornerSoft
			//
			//cv = cvb[0];
			cv = calculateCircleVignetteValue( _width, _img_height, x, y+_offset_height );			
			icv = 255 - cv;
			
			r = mult[softb[0]][icv] + mult[sourceb[0]][cv];
			g = mult[softb[1]][icv] + mult[sourceb[1]][cv];
			b = mult[softb[2]][icv] + mult[sourceb[2]][cv];
			
			r = cornersoft[r][sourceb[0]];
			g = cornersoft[g][sourceb[1]];
			b = cornersoft[b][sourceb[2]];
			
			//diffusion
			//
			r = diffuse[r][softb[0]];
			g = diffuse[g][softb[1]];
			b = diffuse[b][softb[2]];
			
			//circleVignette
			//
			cvf = cvRgb[cv];
			r = r * cvf + RANDDOM_NOISE;
            g = g * cvf + RANDDOM_NOISE;
            b = b * cvf + RANDDOM_NOISE;
			if (r<0) r=0; else if (r>255) r=255;			
			if (g<0) g=0; else if (g>255) g=255;			
			if (b<0) b=0; else if (b>255) b=255;			
			
			//SqrVignette
			//
			//sqrVig = vigb[0];
			sqrVig = calculateSquareVignetteValue( _sqrV_width, _sqrV_height, _sqrV_cornerLength, _sqrV_offsetX, _sqrV_offsetY, x, y+_offset_height );
			fSqrRgb = sqrRgb[sqrVig];
			r = r * fSqrRgb + RANDDOM_NOISE;
			g = g * fSqrRgb + RANDDOM_NOISE;
            b = b * fSqrRgb + RANDDOM_NOISE;
			if (r<0) r=0; else if (r>255) r=255;			
			if (g<0) g=0; else if (g>255) g=255;			
			if (b<0) b=0; else if (b>255) b=255;			
			
			//leak process
			if (lppb)
			{
				r = r + lppb[0];
				g = g + lppb[1];
				b = b + lppb[2];						
				if(r>255) r=255;
				if(g>255) g=255;
				if(b>255) b=255;
			}
			
			//colorClip process
			r = colorClipR[r];
			g = colorClipG[g];
			b = colorClipB[b];		
			
			//monoChrome process
			//
			ccr = r * inverseblendrand;
			ccg = g * inverseblendrand;
			ccb = b * inverseblendrand;
			b = b * bb2 + g * gg + r * rr;
			if(b<0) b=0;
			else if(b>255) b=255;
			r = g = b;
			
			//desat process
			//
			if(doDeSat)
			{
				tempblendrand = r * blendrand;
				r = tempblendrand + ccr;
				g = tempblendrand + ccg;
				b = tempblendrand + ccb;
			}
			
			//add border
			//
			if (borderb) 
			{
				r = mult[r][borderb[0]];
				g = mult[g][borderb[1]];
				b = mult[b][borderb[2]];
			}
            
            // gamma process
            r = gammaRGB[r];
            g = gammaRGB[g];
            b = gammaRGB[b];

			//scurve process
			r = scurveRGB[r];
			g = scurveRGB[g];
			b = scurveRGB[b];
			
			//colorFade process
			r = colorFadeR[r];
			g = colorFadeG[g];
			b = colorFadeB[b];

			*pout++ = (unsigned char)r;    
			*pout++ = (unsigned char)g;    
			*pout++ = (unsigned char)b;    
			*pout++ = (unsigned char)255;
			
			softb += 4;
			sourceb += 4;
			
			if (vigb)
				vigb += 4;
			if (borderb)
				borderb += 4;
			if (lppb)
				lppb += 4;
		}		
	}
	
	return poutb;	
}

unsigned char *pb_render(
					int _width, int _height, int randNum,
					unsigned char *m_cvdata, unsigned char *m_vigdata, unsigned char *m_softdata, unsigned char *m_sourcedata, unsigned char *m_leakdata, unsigned char *m_borderdata,
					ffRGBMaxMin3D _CCrgbMaxMin, ffColor3D _monorgb, ffRGBMaxMin3D _colorFadergbMaxMin, double cornerOpacity, double sCcontrast,
					double cvOpacity, double SqrOpacity, double diffOpacity, double blendrand, double _sqrX, double _sqrY, double gammaCorrection, void*context, int(*progressCallback)(double completion, void* context)
					)
{
	// Full render - no tiling
	pb_Prep_LUT(_CCrgbMaxMin, _monorgb, _colorFadergbMaxMin, cornerOpacity, sCcontrast, cvOpacity, SqrOpacity, diffOpacity, gammaCorrection);
	return pb_tile_render(
				   _width, _height, 0, _height, randNum,
				   m_cvdata, m_vigdata, m_softdata, m_sourcedata, m_leakdata, m_borderdata,
				   blendrand, _sqrX, _sqrY, context, progressCallback
				   );
}

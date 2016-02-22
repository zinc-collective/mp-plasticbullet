/**

	Copyright (c) 2001-2007 Redgiant
	
**/

#pragma once

#include <math.h>

typedef struct
	{
		unsigned char red;
		unsigned char green;
		unsigned char blue;
		unsigned char alpha;
	} FORMAT;

#ifndef M_PI
#define M_PI 3.1415926535897932385
#endif

#define COMPONENT_TYPE unsigned char

#define MAX_LUT_SIZE 4096



#define MIN3(r, g, b) (r<g ? (r<b ? r : b) : (g<b ? g : b) )
#define MAX3(r, g, b) (r>g ? (r>b ? r : b) : (g>b ? g : b) )



#define HSV_PASS(r, g, b)							\
{													\
	float h, s, v;									\
	const float minval = MIN3(r, g, b);				\
	const float maxval = MAX3(r, g, b);				\
	v = maxval;										\
	if(v > 0.f && minval != maxval)					\
	{												\
		const float diffval = maxval - minval;		\
		s = diffval / maxval;						\
		const float Idiffval = 1.f / diffval;		\
		const float rc = (maxval - r) * Idiffval;	\
		const float gc = (maxval - g) * Idiffval;	\
		const float bc = (maxval - b) * Idiffval;	\
		if(r == maxval)	\
			h = bc - gc;	\
		else if(g == maxval)	\
			h = 2.f + rc - bc;	\
		else	\
			h = 4.f + gc - rc;	\
		if(h < 0)	\
			h += 6.0f;	\
	}	\
	else	\
	{	\
		s = 0.f;	\
		h = 0.f;	\
	}	\
	h *= kNormalizeHue;	\
	int hueIndex = (int)(h*kfLutSize_m1 + 0.5f);	\
	const SkinSetting *pSkin = &skinLut[hueIndex];	\
	if(pSkin->notskip)	\
	{	\
		s *= pSkin->sat;	\
		h = pSkin->hue;	\
		h*= 6.f;	\
		if (s < 0.00001F) 	\
		{	\
			r = g = b = v;	\
		} 	\
		else 	\
		{	\
			while (h >= 6.0F)	\
				h -= 6.0F;	\
			while (h < 0.0F) 	\
				h += 6.0F;	\
			if (s > 1.0F) 	\
				s = 1.0F;	\
			const int i = (int)h;	\
			const float f = h - (float)i;	\
			const float p = v * (1.0F - s);	\
			const float q = v * (1.0F - (s*f));	\
			const float t = v * (1.0F - (s*(1.0F-f)));	\
			switch(i) 	\
			{	\
			case 0 : r=v; g=t; b=p; break;	\
			case 1 : r=q; g=v; b=p; break;	\
			case 2 : r=p; g=v; b=t; break;	\
			case 3 : r=p; g=q; b=v; break;	\
			case 4 : r=t; g=p; b=v; break;	\
			case 5 : r=v; g=p; b=q; break;	\
			}	\
		}	\
	}	\
}	\

// http://130.113.54.154/~monger/hsl-rgb.html

#define HSL_HELPER_FUNC(comp, temp1, temp2, temp3)	\
{\
	temp3 = temp3<0.f ? temp3+1.f : temp3>1.f ? temp3-1.f : temp3;\
	if(temp3 < 0.1666666666666667f)\
		comp=temp1+(temp2-temp1)*6.f*temp3;\
	else if (temp3 < 0.5f)\
		comp=temp2;\
	else if (temp3 < 0.66666666666667f)\
		comp=temp1+(temp2-temp1)*(0.66666666666667f-temp3)*6.f;\
	else \
		comp=temp1;\
}\



#define HSL_PASS(r, g, b)	\
{\
	float h, s, l;\
	float min = MIN3(r,g,b);\
	float max = MAX3(r,g,b);\
	l = (min + max)* 0.5f;\
	if (min == max)\
	{\
		s = 0.f;\
		h = 0.f;\
	}\
	else \
	{\
		if (l < 0.5f)\
		{\
			s = (max - min) / (max + min);\
		}\
		else\
		{\
			s = (max - min) / (2.f - max - min);\
		}\
		if (r == max)\
		{\
			h = (g - b)/(max - min);\
		}\
		else if (g == max)\
		{\
			h = 2.f + (b - r)/(max - min);\
		}\
		else\
		{\
			h = 4.f + (r - g)/(max - min);\
		}\
		if (h < 0.f) h += 6.f;\
	}\
	h *= kNormalizeHue;\
	int hueIndex = (int)(h*kfLutSize_m1 + 0.5f);\
	const SkinSetting *pSkin = &skinLut[hueIndex];\
	if(pSkin->notskip)	\
	{	\
		s *= pSkin->sat;	\
		h = pSkin->hue;	\
		h*= 6.f;	\
		if (s == 0.f)\
		{\
			r = l;\
			g = l;\
			b = l;\
		}\
		else\
		{\
			float temp2;\
			if (l < 0.5f)\
			{\
				temp2 = l * (s + 1.f);\
			}\
			else\
			{\
				temp2 = l + s - l*s;\
			}\
			float temp1 = 2.f * l - temp2;\
			h = h * kNormalizeHue;\
			float temp3 = h + 0.33333333333333f;\
			HSL_HELPER_FUNC(r, temp1,temp2, temp3)\
			temp3 = h;\
			HSL_HELPER_FUNC(g, temp1,temp2, temp3)\
			temp3 = h - 0.33333333333333f;\
			HSL_HELPER_FUNC(b, temp1,temp2, temp3)\
		}\
	}\
}\


#define TO_HSL(r, g, b)	\
	float h, s, l;\
	float min = MIN3(r,g,b);\
	float max = MAX3(r,g,b);\
	l = (min + max)* 0.5f;\
	if (min == max)\
	{\
		s = 0.f;\
		h = 0.f;\
	}\
	else \
	{\
		if (l < 0.5f)\
		{\
			s = (max - min) / (max + min);\
		}\
		else\
		{\
			s = (max - min) / (2.f - max - min);\
		}\
		if (r == max)\
		{\
			h = (g - b)/(max - min);\
		}\
		else if (g == max)\
		{\
			h = 2.f + (b - r)/(max - min);\
		}\
		else\
		{\
			h = 4.f + (r - g)/(max - min);\
		}\
		if (h < 0.f) h += 6.f;\
	}\
	h *= kNormalizeHue;\



static float SmoothStep(float a, float b, float x)
{
    if (x < a) 
		return 0.0f;
    else if (x >= b) 
		return 1.0f;
    x = (x - a) / (b - a);
    return (x * x * (3.0f - 2.0f * x));
}

static float SmoothStepFast(float a, float b, float x)
{
    x = (x - a) / (b - a);
    return (x * x * (3.0f - 2.0f * x));
}

static float LinearInterp(float a, float b, float x)
{
    return (x - a) / (b - a);
}

typedef struct
	{	
		double FXid_BlueShadows; 
		double FXid_ShadowTint; 
		double FXid_ShadowPoint; 
		double FXid_WarmCool; 
		double FXid_Contrast; 
		double FXid_Bleach; 
		double FXid_SkinColor; 
		double FXid_SkinSqueeze; 
		double FXid_SkinSolo; 
		bool FXid_ShowSkinOverlay; 
		double FXid_SkinCenter; 
		double FXid_SkinLowHiRadius; 
		double FXid_SkinColorSqueezeMin; 
		double FXid_SkinColorSqueezeMax; 
		double FXid_SkinSoloMin; 
		double FXid_SkinSoloMax; 
		int FXid_LUTSize; 
		int FXid_SkinColorSpace; 
		double FXid_ShowLumaRadius; 
		double FXid_ScopeColor[3]; 
		double FXid_ShowOpacity; 
		int FXid_GridSize; 
		double FXid_BorderSize; 
		double FXid_ScopeRadius; 
		bool FXid_SqueezeNormalize; 
	} RenderArguments;


extern bool checkAbort(int y);

static int PluginRenderHistogramEqualization(const int width,
											 const int height,
											 const int rowbytes,
											 unsigned char *basePtr)
{
	int			err = 0;
	
	int y;
	int maxR = 0;
	int maxG = 0;
	int maxB = 0;	
	for(y=0; y<height; ++y)
	{
//		if(checkAbort(y))
//			return 1;
		FORMAT *oT = (FORMAT *) &basePtr[y*rowbytes];
		for(int x=0; x<width; ++x)
		{
			const int r = oT->red;
			const int g = oT->green;
			const int b = oT->blue;
			if(r>maxR) maxR = r;
			if(g>maxG) maxG = g;
			if(b>maxB) maxB = b;			
			oT++;
		}
	}
	
	const float gainR = maxR != 0 ? 255.f/float(maxR) : 1.f;
	const float gainG = maxG != 0 ? 255.f/float(maxG) : 1.f;
	const float gainB = maxB != 0 ? 255.f/float(maxB) : 1.f;
	
	for(y=0; y<height; ++y)
	{
		if(checkAbort(y))
			return 1;
		FORMAT *oT = (FORMAT *) &basePtr[y*rowbytes];
		for(int x=0; x<width; ++x)
		{
			const float r = float(oT->red)*gainR;
			const float g = float(oT->green)*gainG;
			const float b = float(oT->blue)*gainB;
			if(r>255.f) oT->red=255; else oT->red = (int) (r + 0.5f);
			if(g>255.f) oT->green=255; else oT->green = (int) (g + 0.5f);
			if(b>255.f) oT->blue=255; else oT->blue = (int) (b + 0.5f);
			oT++;
		}
	}
	
	return err;
}


static int PluginRender(
	const RenderArguments &args, 
	const int width,
	const int height,
	const int rowbytes,
	unsigned char *basePtr,
	const float scaleX,
	const float scaleY,
	const float aspect)

{
	int			err = 0;

	const float kFromFloat = float(255.f);
	const float kToFloat = 1.f/kFromFloat;
	const float kHalfRound = 0.5f;
	const float kPivot = 0.5f;
	const float kPivot_m1 = kPivot-1.f;
	const float kInvPivot = 1.f/(kPivot);
	const float kInvPivot_m1 = 1.f/(kPivot_m1);
	const float kContrast = 0.5f;

	const float blueShad = args.FXid_BlueShadows*0.01;
	const float shadTint = args.FXid_ShadowTint*0.01;
	const float shadPoint = args.FXid_ShadowPoint*0.01;
	const float redPivot = 0.7722 * shadPoint;
	const float greenPivot = 0.589 * shadPoint;

	const float wc = args.FXid_WarmCool * 0.01;
	const float wcScale = 0.5f;
	const float kWCRedTerm = pow(2.f, wc*wcScale);
	const float kWCBlueTerm = pow(2.f, -wc*wcScale);
	
	const float kShadRedTerm = (1.f + blueShad*pow(2.f, shadTint));
	const float kShadGreenTerm = (1.f + blueShad*pow(2.f, -shadTint));

	const float kGainOffset = 1.92f;
	const float kGainGain = 0.3955f;
	const float kGainPw = 1.72668f;
	const float expoCompOrig = (pow(shadPoint, kGainPw) + kGainOffset)*kGainGain;
	const float hero = 1.f/0.7f;
	const float expoComp = expoCompOrig*blueShad*hero + (1.f - blueShad*hero);


	const float kRGainFactor = kWCRedTerm*expoComp;
	const float kGGainFactor = expoComp;
	const float kBGainFactor = kWCBlueTerm*expoComp;

	const float kGreenGammaOrig = (pow(MAX(1.f, shadTint)-1.f,2.f) * 0.05f + 1.f);
	const float kGreenGamma = kGreenGammaOrig * blueShad * 4.f + (1.f - blueShad * 4.f);
	const float kInvGreenGamma = 1.f/kGreenGamma;


	const float bleach = args.FXid_Bleach*0.01;
	const float punch = args.FXid_Contrast*0.01;
	const float sat = (1.f-blueShad*0.3f)*(1.f-bleach)*(1-punch*0.2f)*(1-fabs(wc)*0.35f);
	const float Isat = 1.f-sat;

	const float reContrast = (1.f/kContrast) + punch;

	const float skinColor = args.FXid_SkinColor * 0.01;
	const float skinSqueeze = args.FXid_SkinSqueeze * 0.01;
	const float skinSolo = 1.f - (args.FXid_SkinSolo * 0.01);
	bool doSkinPass = (skinColor!=0.f) || (skinSqueeze!=0.f) || (skinSolo!=1.f);

	const float skinSoloCenter	= args.FXid_SkinCenter * 0.01;
	const float skinSoloMin		= args.FXid_SkinSoloMin * 0.01;
	const float skinSoloMax		= args.FXid_SkinSoloMax * 0.01;
//	const float skinSoloInv		= 1.f/(skinSoloMax-skinSoloMin);

	const float kNormalizeHue = 1.f / 6.f;

	const float lutSizeArray[] = {64,128,256,512,1024,4096};
	const int kLutSize = lutSizeArray[ args.FXid_LUTSize ];
//	const int kLutSize_m1 = lutSizeArray[ args.FXid_LUTSize ];
	const float kfLutSize_m1 = float(kLutSize-1);

	typedef struct
	{
		float hue;
		float sat;
		bool notskip;
	} SkinSetting;
	SkinSetting skinLut[MAX_LUT_SIZE+1];
	if(doSkinPass)
	{
		int i;
		for(i=0; i<kLutSize; ++i)
		{
			if(checkAbort(i))
				return 1;
			const float unorm = (float(i)/kfLutSize_m1) + 0.5f - skinSoloCenter;
			const float f = unorm>1.f ? unorm-1.f : unorm<0.f ? 1.f+unorm : unorm;

			if(f<skinSoloMin)
				skinLut[i].sat = skinSolo;
			else if(f<0.5f)
			{
				float mix = SmoothStepFast(skinSoloMin, 0.5f, f);
				skinLut[i].sat = mix + (1.f-mix)*skinSolo;
			}
			else if(f<skinSoloMax)
			{
				float mix = SmoothStepFast(0.5f, skinSoloMax, f);
				skinLut[i].sat = (1.f-mix) + mix*skinSolo;
			}
			else
				skinLut[i].sat = skinSolo;
		}
		skinLut[MAX_LUT_SIZE].sat = skinLut[MAX_LUT_SIZE-1].sat;
	}

	const float skinColorSqueezeCenter = args.FXid_SkinCenter * 0.01;
	const float skinColorSqueezeRadius = (args.FXid_SkinLowHiRadius* 0.01);
	const float skinColorSqueezeMin = args.FXid_SkinColorSqueezeMin* 0.01;
	const float skinColorSqueezeMax = args.FXid_SkinColorSqueezeMax* 0.01;
	const float skinColorSqueezeLo = 0.5f - skinColorSqueezeRadius;
	const float skinColorSqueezeHi = 0.5f + skinColorSqueezeRadius;
	const float skinColorSqueezeFactor = 10.f/100.f;
	
	float skinSqueezeMaxDist = skinSqueeze*skinColorSqueezeFactor;
	if(args.FXid_SqueezeNormalize)
	{
		skinSqueezeMaxDist = skinSqueeze*skinColorSqueezeRadius;
	}
	const float skinLoY			= (skinColor*skinColorSqueezeFactor) + skinSqueezeMaxDist;
	const float skinHiY			= (skinColor*skinColorSqueezeFactor) - skinSqueezeMaxDist;
	if(doSkinPass)
	{	
		int i;
		for(i=0; i<kLutSize; ++i)
		{
			if(checkAbort(i))
				return 1;
			const float unorm = (float(i)/kfLutSize_m1) + 0.5f - skinColorSqueezeCenter;
			const float f = unorm>1.f ? unorm-1.f : unorm<0.f ? 1.f+unorm : unorm;

			float hue;
			if(args.FXid_SqueezeNormalize)
			{
				float yStart, yEnd;
				if(f<skinColorSqueezeMin)
				{
					yStart = 0.f;
					yEnd = f;
				}
				else if(f<skinColorSqueezeLo)
				{
					yStart = f;
					yEnd = skinColorSqueezeLo+skinLoY;
				}
				else if(f<skinColorSqueezeHi)
				{
					yStart = skinColorSqueezeLo+skinLoY;
					yEnd = skinColorSqueezeHi+skinHiY;
				}
				else if(f<skinColorSqueezeMax)
				{
					yStart = skinColorSqueezeHi+skinHiY;
					yEnd = f;
				}
				else
				{
					yStart = f;
					yEnd = 1.f;
				}

				// Smoothstep
				if(f<skinColorSqueezeMin)
				{
					hue = f;
				}
				else if(f<skinColorSqueezeLo)
				{
					float mix = SmoothStepFast(skinColorSqueezeMin, skinColorSqueezeLo, f);
					hue = mix*yEnd + (1.f-mix)*yStart;
				}
				else if(f<skinColorSqueezeHi)
				{
					float mix = SmoothStepFast(skinColorSqueezeLo, skinColorSqueezeHi, f);
					hue = mix*yEnd + (1.f-mix)*yStart;
				}
				else if(f<skinColorSqueezeMax)
				{
					float mix = SmoothStepFast(skinColorSqueezeHi, skinColorSqueezeMax, f);
					hue = mix*yEnd + (1.f-mix)*yStart;
				}
				else
				{
					hue = f;
				}

				hue += (float(i)/kfLutSize_m1)-f;

			}
			else
			{
				if(f<skinColorSqueezeMin)
					hue = 0.f;
				else if(f<skinColorSqueezeLo)
				{
					float mix = SmoothStepFast(skinColorSqueezeMin, skinColorSqueezeLo, f);
					hue = mix*skinLoY;
				}
				else if(f<skinColorSqueezeHi)
				{
					float mix = SmoothStepFast(skinColorSqueezeLo, skinColorSqueezeHi, f);
					hue = mix*skinHiY + (1.f-mix)*skinLoY;
				}
				else if(f<skinColorSqueezeMax)
				{
					float mix = SmoothStepFast(skinColorSqueezeHi, skinColorSqueezeMax, f);
					hue = (1.f-mix)*skinHiY;
				}
				else
					hue = 0.f;
				hue += float(i)/kfLutSize_m1;
			}

			skinLut[i].hue = hue; 

			skinLut[i].notskip = (skinLut[i].hue != 0.f) || (skinLut[i].sat != 1.f);
		}
		skinLut[MAX_LUT_SIZE].hue = skinLut[MAX_LUT_SIZE-1].hue;
		skinLut[MAX_LUT_SIZE].notskip = skinLut[MAX_LUT_SIZE-1].notskip;
	}


	float rPreLut[MAX_LUT_SIZE+1];
	float gPreLut[MAX_LUT_SIZE+1];
	float bPreLut[MAX_LUT_SIZE+1];
	COMPONENT_TYPE rgbPostLut[MAX_LUT_SIZE+1];
	{
		int i;
		for(i=0; i<kLutSize; ++i)
		{
			if(checkAbort(i))
				return 1;
			const float f = float(i)/kfLutSize_m1;
			float pre = f;
			// Uncontrast
			if(pre>=kPivot)
				pre = (pow((pre-1.f)*kInvPivot_m1, kContrast)* kPivot_m1) + 1.f;
			else
				pre = (pow(pre*kInvPivot, kContrast)* kPivot);

			// Shadow
			float r = ((pre-redPivot)*kShadRedTerm) + redPivot;
			float g = ((pre-greenPivot)*kShadGreenTerm) + greenPivot;
			float b = (pre);
			// Gamma
			g = MAX(g, 0.f);
			g = pow(g, kInvGreenGamma);
			// Warm-Cool
			r *= kRGainFactor;
			g *= kGGainFactor;
			b *= kBGainFactor;

			rPreLut[i] = r;
			gPreLut[i] = g;
			bPreLut[i] = b;

			float post = f;
			// Contrast
			if(post>=kPivot)
				post = (pow((post-1.f)*kInvPivot_m1, reContrast)* kPivot_m1) + 1.f;
			else
				post = (pow(post*kInvPivot, reContrast)* kPivot);

			int c = post*kFromFloat + kHalfRound;
			rgbPostLut[i] = c<0?0:c>255?255:c;
		}
	}




	{
		if(doSkinPass && args.FXid_SkinColorSpace == 0)
		{
			int y;
			for(y=0; y<height; ++y)
			{
				if(checkAbort(y))
					return 1;
				FORMAT *oT = (FORMAT *) &basePtr[y*rowbytes];
				for(int x=0; x<width; ++x)
				{
					float r = float(oT->red)*kToFloat;
					float g = float(oT->green)*kToFloat;
					float b = float(oT->blue)*kToFloat;

					// Skin
					HSV_PASS(r, g, b)

					// Uncontrast + Shadow + Warm-Cool
					r = rPreLut[(int)(r*kfLutSize_m1 + 0.5f)];
					g = gPreLut[(int)(g*kfLutSize_m1 + 0.5f)];
					b = bPreLut[(int)(b*kfLutSize_m1 + 0.5f)];

					// Bleach
					const float mono = (r*0.2126f + g*0.7152f + b*0.0722f)*Isat;
					r = r*sat + mono;
					g = g*sat + mono;
					b = b*sat + mono;
					
					// Clamp
					if(r<0.f) r = 0.f; else if(r>1.f) r = 1.f;
					if(g<0.f) g = 0.f; else if(g>1.f) g = 1.f;
					if(b<0.f) b = 0.f; else if(b>1.f) b = 1.f;

					// Contrast
					oT->red = rgbPostLut[(int)(r*kfLutSize_m1 + 0.5f)];
					oT->green = rgbPostLut[(int)(g*kfLutSize_m1 + 0.5f)];
					oT->blue = rgbPostLut[(int)(b*kfLutSize_m1 + 0.5f)];

					oT++;
				}
			}
		}
		else if(doSkinPass && args.FXid_SkinColorSpace == 1)
		{
			int y;
			for(y=0; y<height; ++y)
			{
				if(checkAbort(y))
					return 1;
				FORMAT *oT = (FORMAT *) &basePtr[y*rowbytes];
				for(int x=0; x<width; ++x)
				{
					float r = float(oT->red)*kToFloat;
					float g = float(oT->green)*kToFloat;
					float b = float(oT->blue)*kToFloat;

					// Skin
					HSL_PASS(r, g, b)

					// Uncontrast + Shadow + Warm-Cool
					r = rPreLut[(int)(r*kfLutSize_m1 + 0.5f)];
					g = gPreLut[(int)(g*kfLutSize_m1 + 0.5f)];
					b = bPreLut[(int)(b*kfLutSize_m1 + 0.5f)];

					// Bleach
					const float mono = (r*0.2126f + g*0.7152f + b*0.0722f)*Isat;
					r = r*sat + mono;
					g = g*sat + mono;
					b = b*sat + mono;
					
					// Clamp
					if(r<0.f) r = 0.f; else if(r>1.f) r = 1.f;
					if(g<0.f) g = 0.f; else if(g>1.f) g = 1.f;
					if(b<0.f) b = 0.f; else if(b>1.f) b = 1.f;

					// Contrast
					oT->red = rgbPostLut[(int)(r*kfLutSize_m1 + 0.5f)];
					oT->green = rgbPostLut[(int)(g*kfLutSize_m1 + 0.5f)];
					oT->blue = rgbPostLut[(int)(b*kfLutSize_m1 + 0.5f)];

					oT++;
				}
			}
		}
		else
		{
			int y;
			for(y=0; y<height; ++y)
			{
				if(checkAbort(y))
					return 1;
				FORMAT *oT = (FORMAT *) &basePtr[y*rowbytes];
				for(int x=0; x<width; ++x)
				{
					float r = float(oT->red)*kToFloat;
					float g = float(oT->green)*kToFloat;
					float b = float(oT->blue)*kToFloat;

					// Uncontrast + Shadow + Warm-Cool
					r = rPreLut[(int)(r*kfLutSize_m1 + 0.5f)];
					g = gPreLut[(int)(g*kfLutSize_m1 + 0.5f)];
					b = bPreLut[(int)(b*kfLutSize_m1 + 0.5f)];

					// Bleach
					const float mono = (r*0.2126f + g*0.7152f + b*0.0722f)*Isat;
					r = r*sat + mono;
					g = g*sat + mono;
					b = b*sat + mono;
					
					// Clamp
					if(r<0.f) r = 0.f; else if(r>1.f) r = 1.f;
					if(g<0.f) g = 0.f; else if(g>1.f) g = 1.f;
					if(b<0.f) b = 0.f; else if(b>1.f) b = 1.f;

					// Contrast
					oT->red = rgbPostLut[(int)(r*kfLutSize_m1 + 0.5f)];
					oT->green = rgbPostLut[(int)(g*kfLutSize_m1 + 0.5f)];
					oT->blue = rgbPostLut[(int)(b*kfLutSize_m1 + 0.5f)];

					oT++;
				}
			}
		}
	}

	if(args.FXid_ShowSkinOverlay)
	{
		const float lumaRadius = args.FXid_ShowLumaRadius*0.01;
		const float IlumaRadius = 1.f-lumaRadius;
		const float scopeOpacity = args.FXid_ShowOpacity*0.01;
		const float rScopeCol = args.FXid_ScopeColor[0];
		const float gScopeCol = args.FXid_ScopeColor[1];
		const float bScopeCol = args.FXid_ScopeColor[2];
//		const float IscopeOpacity = 1.f-scopeOpacity;
		const float scopeRadius = args.FXid_ScopeRadius*0.01;
		float borderSizeX = (float) args.FXid_BorderSize;
		float borderSizeY = (float) args.FXid_BorderSize;
		int gridSize = args.FXid_GridSize;
		float gridSizeX = (float) (float(width)/(float(gridSize)));
		float gridSizeY = (float) (float(aspect*width)/(float(gridSize)));
		borderSizeX = float(borderSizeX*float(width))/500.f;
		borderSizeY = float(aspect*borderSizeY*float(width))/500.f;

		int y;
		for(y=0; y<height; ++y)
		{
			if(checkAbort(y))
				return 1;
			FORMAT *oT = (FORMAT *) &basePtr[y*rowbytes];

			int iy = int(floor(float(y)/gridSizeY));
			float fy0 = gridSizeY*float(iy);
			float fy1 = fy0 + borderSizeY;
			float fy2 = gridSizeY*float(iy+1);
			float fy3 = fy2 + borderSizeY;
			float opacityGridY =  0.f;
			int iy0 = (int)floor(fy0);
			int iy1 = (int)floor(fy1);
			int iy2 = (int)floor(fy2);
			int iy3 = (int)floor(fy3);
			if(y>=iy0 && y<=iy1)
			{
				if(y==iy0)
					opacityGridY =  1.f-(fy0-float(iy0));
				else if(y==iy1)
					opacityGridY =  (fy1-float(iy1));
				else
					opacityGridY = 1.f;
			}
			else if(y>=iy2 && y<=iy3)
			{
				if(y==iy2)
					opacityGridY =  1.f-(fy2-float(iy2));
				else if(y==iy3)
					opacityGridY =  (fy3-float(iy3));
				else
					opacityGridY = 1.f;
			}

			for(int x=0; x<width; ++x)
			{
				int ix = int(floor(float(x)/gridSizeX));
				float fx0 = gridSizeX*float(ix);
				float fx1 = fx0 + borderSizeX;
				float fx2 = gridSizeX*float(ix+1);
				float fx3 = fx2 + borderSizeX;
				float opacityGridX =  0.f;
				int ix0 = (int)floor(fx0);
				int ix1 = (int)floor(fx1);
				int ix2 = (int)floor(fx2);
				int ix3 = (int)floor(fx3);
				if(x>=ix0 && x<=ix1)
				{
					if(x==ix0)
						opacityGridX =  1.f-(fx0-float(ix0));
					else if(x==ix1)
						opacityGridX =  (fx1-float(ix1));
					else
						opacityGridX = 1.f;
				}
				else if(x>=ix2 && x<=ix3)
				{
					if(x==ix2)
						opacityGridX =  1.f-(fx2-float(ix2));
					else if(x==ix3)
						opacityGridX =  (fx3-float(ix3));
					else
						opacityGridX = 1.f;
				}
				float opacityGrid = MAX(opacityGridX, opacityGridY);
				if(opacityGrid==0.f)
				{
					oT++;
					continue;
				}

				float r = float(oT->red)*kToFloat;
				float g = float(oT->green)*kToFloat;
				float b = float(oT->blue)*kToFloat;

				TO_HSL(r, g, b)

				// Center Hue
				h = (h-skinColorSqueezeCenter)+0.5f;
				float hueMatte = fabs(h - 0.5f);
				hueMatte = LinearInterp(0.f, scopeRadius, hueMatte); 
				if(hueMatte<0.f)
					hueMatte = 0.f;
				else if(hueMatte>1.f)
					hueMatte = 1.f;
				hueMatte = 1.f - hueMatte;
				if(hueMatte == 0.f)
				{
					oT++;
					continue;
				}
				float luminanceBlacks = LinearInterp(0.f, lumaRadius, l);
				if(luminanceBlacks<=0.f) 
				{
					oT++;
					continue;
				}
				else if(luminanceBlacks>1.f) 
					luminanceBlacks = 1.f;
				float luminanceWhites = LinearInterp(IlumaRadius, 1.f, l);
				if(luminanceWhites<0.f) 
					luminanceWhites = 0.f; 
				else if(luminanceWhites>=1.f) 
				{
					oT++;
					continue;
				}
				luminanceWhites = 1.f - luminanceWhites;
				float matte = hueMatte*luminanceBlacks*luminanceWhites * scopeOpacity * opacityGrid;

				r = (1.f-matte)*r + rScopeCol*matte;
				g = (1.f-matte)*g + gScopeCol*matte;
				b = (1.f-matte)*b + bScopeCol*matte;
				
				int rc = r*kFromFloat + kHalfRound;
				oT->red = rc<0?0:rc>255?255:rc;
				
				int gc = g*kFromFloat + kHalfRound;
				oT->green = gc<0?0:gc>255?255:gc;

				int bc = b*kFromFloat + kHalfRound;
				oT->blue = bc<0?0:bc>255?255:bc;


				oT++;
			}
		}

	}


	return err;
}

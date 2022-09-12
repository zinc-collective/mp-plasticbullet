#include <stdlib.h>
#include "fastBlur.h"

unsigned char* fast_blur(unsigned char* _srcImg, int s_radius, int width, int height)
{
	int kernel_size = s_radius*2 + 1;
	int kernel_area = kernel_size * kernel_size;
	
	int theWidth = width;
	int theHeight = height;
	
	unsigned int**tmpRows = (unsigned int**) malloc(kernel_size * sizeof(unsigned int*));
	if (!tmpRows)
	{
		return NULL;
	}
	
	for (int i=0; i<kernel_size; i++)
	{
		tmpRows[i] = (unsigned int *)malloc(theWidth * 3 * sizeof(unsigned int));
		if (!tmpRows[i])
		{
			for (int j=i-1; j>=0; j--)
				free(tmpRows[j]);
			free(tmpRows);
			return NULL;
		}
	}
	
	unsigned int *subTotalHead, *subtotal;
	subTotalHead = subtotal = (unsigned int *)malloc(theWidth * 3 * sizeof(unsigned int));
	if (!subtotal)
	{
		for (int i=0; i<kernel_size; i++)
		{
			free(tmpRows[i]);
		}
		free(tmpRows);
		return NULL;
	}
	
	// Clear accumlation buffer
	//
	for (int j=0; j<theWidth * 3; j++)
	{
		*subtotal++ = 0;
	}
	unsigned int *tmpRowPtr = NULL;
	for (int i=0; i<kernel_size; i++) 
	{
		tmpRowPtr = (unsigned int *) tmpRows[i];
		for (int j=0; j<theWidth * 3; j++)
		{
			*tmpRowPtr++ = 0;
		}
	}	
	
	// Store the blur value to output buffer
	//
	unsigned char *pout, *poutb;
	pout = poutb = (unsigned char *)malloc(theWidth * theHeight * 4);   		
	if (!pout)
	{
		for (int i=0; i<kernel_size; i++)
		{
			free(tmpRows[i]);
		}
		free(tmpRows);
		free(subtotal);
		return NULL;
	}	
	
	// Run length variables;
	unsigned int runningSum[3];
	unsigned int *tmpColR = (unsigned int *)malloc(kernel_size * sizeof(unsigned int));
	unsigned int *tmpColG = (unsigned int *)malloc(kernel_size * sizeof(unsigned int));
	unsigned int *tmpColB = (unsigned int *)malloc(kernel_size * sizeof(unsigned int));
	if (!tmpColR || !tmpColG || !tmpColB)
	{
		for (int i=0; i<kernel_size; i++)
		{
			free(tmpRows[i]);
		}
		free(tmpRows);
		free(subtotal);
		if (!tmpColR)
			free(tmpColR);
		if (!tmpColG)
			free(tmpColG);
		if (!tmpColB)
			free(tmpColB);
		return NULL;
	}
	
	int lastBottomIdx = 0;
	for (int yy = -s_radius, loadedRow = 0; yy < theHeight; yy++, loadedRow++) 
	{    
		int bottomIdx = loadedRow%kernel_size;
		
		//Subtract the previous row
		//
		tmpRowPtr = tmpRows[bottomIdx];
		subtotal = subTotalHead;		
		for (int xx = 0; xx < theWidth; xx++) 
		{
			*subtotal++ -= (unsigned int) *tmpRowPtr++;	
			*subtotal++ -= (unsigned int) *tmpRowPtr++;	
			*subtotal++ -= (unsigned int) *tmpRowPtr++;	
		}
		
		//Load the new row
		//
		tmpRowPtr = tmpRows[bottomIdx];
		if (loadedRow < theHeight)
		{
			lastBottomIdx = bottomIdx;
			
			// linear blur for each row
			//
			unsigned char	*_src = (unsigned char *)&_srcImg[loadedRow*theWidth*4];
			
			// initialize the left side to avoid black border
			//
			runningSum[0] = 0;
			runningSum[1] = 0;
			runningSum[2] = 0;
			for ( int j=0; j<kernel_size; j++ )
			{
				tmpColR[j] = _src[0];
				tmpColG[j] = _src[1];
				tmpColB[j] = _src[2];
				
				runningSum[0] += tmpColR[j];
				runningSum[1] += tmpColG[j];
				runningSum[2] += tmpColB[j];
			}
			
			// Blur the row
			int lastIdx = 0;
			for ( int j=-s_radius, rightIdx=0; j<theWidth; j++, rightIdx++)
			{
				int idx = rightIdx%kernel_size;
				
				// Subtract old pixels
				runningSum[0] -= tmpColR[idx];
				runningSum[1] -= tmpColG[idx];
				runningSum[2] -= tmpColB[idx];			
				
				if ( rightIdx < theWidth )
				{
					// retrieve source
					//
					tmpColR[idx] = (unsigned char) *_src++;
					tmpColG[idx] = (unsigned char) *_src++;
					tmpColB[idx] = (unsigned char) *_src++;
					_src++;
					
					lastIdx = idx;
				}
				else 
				{
					// Repeat the right side to avoid black border
					//
					tmpColR[idx] = tmpColR[lastIdx];
					tmpColG[idx] = tmpColG[lastIdx];
					tmpColB[idx] = tmpColB[lastIdx];					
				}
				
				runningSum[0] += tmpColR[idx];
				runningSum[1] += tmpColG[idx];
				runningSum[2] += tmpColB[idx];
				
				if ( j >= 0 )
				{
					// Could write to output buffer
					//
					*tmpRowPtr++ = runningSum[0];
					*tmpRowPtr++ = runningSum[1];
					*tmpRowPtr++ = runningSum[2];
				}
			}
			
			// Add to total
			//
			tmpRowPtr = tmpRows[bottomIdx];
			subtotal = subTotalHead;		
			for (int j=0; j<theWidth; j++) 
			{			
				*subtotal++ += *tmpRowPtr++;
				*subtotal++ += *tmpRowPtr++;
				*subtotal++ += *tmpRowPtr++;
			}
			
			if (loadedRow==0)
			{
				// First row - accumulate the border to avoid black edge
				//
				unsigned int *tmpFirstRows;
				for ( int j=1; j<kernel_size; j++ )
				{
					tmpFirstRows = tmpRows[bottomIdx];
					tmpRowPtr = tmpRows[j];
					subtotal = subTotalHead;		
					for (int j=0; j<theWidth; j++) 
					{			
						*tmpRowPtr++ = *tmpFirstRows;
						*tmpRowPtr++ = *(tmpFirstRows+1);
						*tmpRowPtr++ = *(tmpFirstRows+2);

						*subtotal++ += *tmpFirstRows++;
						*subtotal++ += *tmpFirstRows++;
						*subtotal++ += *tmpFirstRows++;
					}
				}
			}
		}
		else 
		{
			// Repeat the bottom side to avoid black border
			//
			unsigned int *tmpLastRowPtr = tmpRows[lastBottomIdx];
			subtotal = subTotalHead;		
			for (int j=0; j<theWidth * 3; j++, tmpRowPtr++) 
			{			
				*tmpRowPtr = *tmpLastRowPtr++;
				*subtotal++ += *tmpRowPtr;
			}
		}
		
		if ( yy >= 0 )
		{
			// Could write to output buffer
			//
			subtotal = subTotalHead;		
			for (int xx = 0; xx < theWidth; xx++) 
			{				
				*pout++ = (unsigned char) (*subtotal++ / kernel_area);
				*pout++ = (unsigned char) (*subtotal++ / kernel_area);
				*pout++ = (unsigned char) (*subtotal++ / kernel_area);
				*pout++ = (unsigned char) 255;				
			}
		}
	}
	
	// Free buffers
	for (int i=0; i<kernel_size; i++)
	{
		free(tmpRows[i]);   		
	}
	free(subTotalHead);
	free(tmpRows);
	free(tmpColR);
	free(tmpColG);
	free(tmpColB);
	
	return poutb;
}	

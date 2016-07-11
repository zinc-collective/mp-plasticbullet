#ifndef PBRENDER
#define PBRENDER

#include "RenderArguments.h"

void pb_Prep_LUT(
				 ffRGBMaxMin3D _CCrgbMaxMin, ffColor3D _monorgb, ffRGBMaxMin3D _colorFadergbMaxMin, double cornerOpacity, double sCcontrast,
				 double cvOpacity, double SqrOpacity, double diffOpacity 
				 );

unsigned char *pb_tile_render(
				int _width, int _height, int _offset_height, int _img_height, int randNum,
				unsigned char *m_cvdata, unsigned char *m_vigdata, unsigned char *m_softdata, unsigned char *m_sourcedata, unsigned char *m_leakdata, unsigned char *m_borderdata,
				double blendrand, double _sqrX, double _sqrY, void* context, int(*progressCallback)(double completion, void* context)
				);

unsigned char *pb_render(
			   int _width, int _height, int randNum,
			   unsigned char *m_cvdata, unsigned char *m_vigdata, unsigned char *m_softdata, unsigned char *m_sourcedata, unsigned char *m_leakdata, unsigned char *m_borderdata,
			   ffRGBMaxMin3D _CCrgbMaxMin, ffColor3D _monorgb, ffRGBMaxMin3D _colorFadergbMaxMin, double cornerOpacity, double sCcontrast,
			   double cvOpacity, double SqrOpacity, double diffOpacity, double blendrand, double _sqrX, double _sqrY, void* context, int(*progressCallback)(double degree, void* context)
			   );

#endif
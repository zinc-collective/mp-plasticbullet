
#include<stdlib.h>
#include<stdio.h>
#include<stdint.h>

long filesize(FILE *stream)
{
	long curpos, length;
	curpos = ftell(stream);
	fseek(stream, 0L, SEEK_END);
	length = ftell(stream);
	fseek(stream, curpos, SEEK_SET);
	
	return length;
}

long filelength(const char* filepath){
	
	FILE* fp = fopen(filepath, "r");
	
	long lRes = filesize(fp);
	
	fclose(fp);
	return lRes;
}

int readFile(unsigned char*output, const char* filepath, size_t offset, size_t length){
	
	FILE* fp = fopen(filepath, "r");
	
	int iRes = 0;
	
	if(fp){
		fseek(fp, offset, SEEK_SET);
		iRes = (int)fread(output, sizeof(uint8_t), length, fp);
		fclose(fp);
	}
	
	return iRes;
}
FILE *createFile(const char* filepath){
	
	FILE* fp = fopen(filepath, "a+");
	
	return fp;
}

void closeBinaryFile(FILE *fp){
	fclose(fp);
}

int appendFile(FILE *fp, const char* input, long length){
	
	if(!fp)return 0;
	
	//int iRes = fputs(input, fp);
	int iRes = (int)fwrite (input,1 , length, fp );
	return iRes;
}
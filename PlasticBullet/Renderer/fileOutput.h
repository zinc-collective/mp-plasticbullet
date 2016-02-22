
#ifndef FILEOUTPUT
#define FILEOUTPUT



long filelength(const char* filepath);

int readFile(unsigned char*output, const char* filepath, size_t offset, size_t length);

FILE* createFile(const char* filepath);
int appendFile(FILE *fp, const char* input, long length);
void closeBinaryFile(FILE *fp);

#endif /* FILEOUTPUT */
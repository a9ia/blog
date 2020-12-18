---
layout: post
title: 哈夫曼树解压缩
excerpt: '哈夫曼树解压缩实现'
date: 2020-12-16 16:02:59
tags:
---







# 哈夫曼解压缩



## 描述

利用哈夫曼编码进行信息通信可以大大提高信道利用率，缩短信息传输时间，降低传输成本。但是，要求在发送端通过一个编码系统对传输数据预先编码（压缩）；在接收端将传来的数据进行译码（解压缩复原）。试为这样的通信站编写一个哈夫曼编译码系统---哈夫曼压缩/解压缩算法。



## 要求

1）通信内容可以是任意的多媒体文件；

 2）自己设定字符大小，统计该文件中不同字符的种类（字符集、个数）、出现频率（在该文件中）；

 3）构建相应的哈夫曼树，并给出个字符的哈夫曼编码；

 4）对源文件进行哈夫曼压缩编码形成新的压缩后文件（包括哈夫曼树）；

 5）编写解压缩文件对压缩后文件进行解码还原成源文件。

 6）不同源文件形成的压缩文件中应该包含相应的哈夫曼树结构，以便解压缩系统直接译码还原之。



## 需求分析

+ 需要统计各种文件类型二进制形式的字符出现频数
+ 依据频数构建哈夫曼树，并将哈夫曼树编码记录
+ 依据哈夫曼树编码进行压缩



+ 利用文件的哈夫曼树进行解压缩



## 实战

**结构体，读入并统计文件字符出现频数大部分参考** [哈夫曼压缩与解压缩_飞鸿踏雪泥](https://blog.csdn.net/weixin_38214171/article/details/81626498)

### 文件结构

![image-20201216192537492](https://cdn.jsdelivr.net/gh/a9ia/image//blog/image-20201216192537492.png)



### 结构体

```
/*
** struct.c
*/

#include <stdio.h>
#include <stdlib.h>

typedef struct CHAR {
    unsigned char charbody;
    int freq;
} TEXT;
```



### 读入并统计文件字符出现频数



```
/*
** charFrequency.c
*/

#include "struct.c"

TEXT *getNum(char *Filename, int *len) {
    FILE *fp = fopen(Filename,"rb");
    TEXT *charFreq = NULL;
    unsigned char ch;
    int i, temp, freq[256] = {0}, index = 0;
    if(fp == NULL) {
      perror("无法打开文件");
      exit(0);
    };

    /*
    ** 统计不同字符的频度
    */
    while( !feof(fp) ) {
      temp = fgetc(fp);
      freq[temp]++;

      /*
      ** 统计字符种类的数目
      */
      if( freq[temp] == 1 ) {
        (*len)++;
      }
    }

    /*
    **  创建种类数目的空间
    */
    charFreq = (TEXT *) calloc(sizeof(TEXT), *len);
    for ( i = 0; i < 256; i++ ) {
      if( freq[i] ) {
        charFreq[index].charbody = i;
        charFreq[index].freq = freq[i];
        index ++;
      }
    }
    fclose(fp);
    return charFreq;
}
```



### 生成哈夫曼树进行编码

```
#include "struct.c"

void quickSort( CODING *content, int qlen ) {
    int j = 0, i, max = qlen, change = 1;
    stack head, *p, *tempStack;
    head.top = NULL;
    CODING temp;
    if( qlen == 1 ) { return; }
    while( j < qlen - 1 ) {
        for( i = j + 1; i < max; i++ ) {
            if( content[i].charFreq.freq < content[j].charFreq.freq ) {
                temp = content[i + change];
                content[i + change] = content[i];
                content[i] = temp;
                change++;
            }
        }
        if( change == 2 && j + 2 <= qlen ) {
            temp = content[j];
            content[j] = content[j + change - 1];
            content[j + change - 1] = temp;
            j = j + 2;
        } else if( change > 2 ) {
            temp = content[j];
            content[j] = content[j + change - 1];
            content[j + change - 1] = temp;
            tempStack = (stack *) calloc(sizeof(stack), 1);
            (*tempStack).num = j + change - 1;
            (*tempStack).top = p;
            *p = *tempStack;
            change = 1;
        } else {
            j++;
        }
        while( j >= max - 1 && max < qlen ) {
            tempStack = (*p).top;
            free(p);
            if( (*tempStack).top == NULL ) {
                max = qlen;
                *p = head;
            } else {
                p = tempStack;
                max = (*p).num;
            }
        }
    }
}

void boob( int *content, int p, int qlen, CODING *charFreq) {
    int i = p, temp = content[p];
    while(i < qlen && charFreq[content[i+1]].charFreq.freq < charFreq[temp].charFreq.freq) {
        content[i] = content[i+1];
        i++;
    }
    content[i] = temp;
}

CODING *createHaffmanCode( TEXT *charFreq, int len ) {
    CODING *charTree = (CODING *)malloc(sizeof(CODING), len);
    int *content = (int *)malloc(sizeof(int), len);
    int i = 0;
    for( i; i < len; i++) {
        charTree[i].charFreq = charFreq[i];
        charTree[i].visited = F;
    }
    quickSort(charTree, len);
}
```


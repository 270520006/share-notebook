# IO流读写操作

![IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled.png](IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled.png)

[四个抽象类](IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/%E5%9B%9B%E4%B8%AA%E6%8A%BD%E8%B1%A1%E7%B1%BB%20f4f12ac74028467d9c0f0323d6877613.csv)

## FileInputStream&FileOutputStream文件字节流

1. FileInputStream:通过字节的方式读取文件，适合读取所有类型的文件(图像、视频等)，全字符请考虑FileReader

    ![IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%201.png](IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%201.png)

2. FileOutputStream:通过字节的方式写出或追加数据到文件，适合所有类型的文件(图像、视频等),全字符请考虑FileWriter

    ![IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%202.png](IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%202.png)

## 拷贝

![IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%203.png](IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%203.png)

## FileReader&FileWriter文件字符流

- FileReader:通过字符的方式读取文件，仅适合字符文件

![IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%204.png](IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%204.png)

- FileWriter:通过字节的方式写出或追加数据到文件中，仅适合字符文件

![IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%205.png](IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%205.png)

## ByteArrayInputStream&ByteArrayOutputStream字节数组流

![IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%206.png](IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%206.png)

![IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%207.png](IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%207.png)

## BufferedInputStream&BufferedOutputStream字节缓冲流

![IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%208.png](IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%208.png)

![IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%209.png](IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%209.png)

## BufferedReader&BufferedWriter字符缓冲流

![IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%2010.png](IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%2010.png)

![IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%2011.png](IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%2011.png)

## InputStreamReader&OutputStreamWriter转换流

![IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%2012.png](IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%2012.png)

## DataInputStream&DataOutputStream数据流

![IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%2013.png](IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%2013.png)

## ObjectInputStream&ObjectOutputStream对象流

![IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%2014.png](IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%2014.png)

## PrintStream打印流

![IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%2015.png](IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%2015.png)

## RandomAccessFile随机流

![IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%2016.png](IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%2016.png)

## SequenceInputStream合并流

![IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%2017.png](IO%E6%B5%81%E8%AF%BB%E5%86%99%E6%93%8D%E4%BD%9C%203e2a369ada5e4dcfab8396c03be4eccd/Untitled%2017.png)
//
//  DfuDownloadFile.m
//  RideHousekeeper
//
//  Created by Apple on 2017/7/12.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "DfuDownloadFile.h"

@interface DfuDownloadFile()

@property(nonatomic,strong)NSMutableData *fileData;
//文件句柄
@property(nonatomic,strong)NSFileHandle *writeHandle;
//当前获取到的数据长度
@property(nonatomic,assign)long long currentLength;
//完整数据长度
@property(nonatomic,assign)long long sumLength;

//请求对象
@property(nonatomic,strong)NSURLConnection *cnnt;


@end

@implementation DfuDownloadFile


/**
 *  固件升级模式
 */

- (void)startDownload:(NSString *)downloadHttp{
    
    if ([self isFileExist:Downloadfile]) {
        [self deleteFile];
    }
    
    //创建下载路径
    NSURL *url=[NSURL URLWithString:downloadHttp];
    
    //创建一个请求
    //NSURLRequest *request=[NSURLRequest requestWithURL:url];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    
    //设置请求头信息
    //self.currentLength字节部分重新开始读取
    NSString *value=[NSString stringWithFormat:@"bytes=%lld-",self.currentLength];
    [request setValue:value forHTTPHeaderField:@"Range"];
    
    //发送请求（使用代理的方式）
    self.cnnt=[NSURLConnection connectionWithRequest:request delegate:self];
    [self.cnnt start];
}

#pragma mark- NSURLConnectionDataDelegate代理方法
/*
 *当接收到服务器的响应（连通了服务器）时会调用
 */
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (self.sumLength) return;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", pathDocuments,Downloadfile];
    // NSString *createDir = [NSString stringWithFormat:@"%@/MessageQueueImage", pathDocuments];
    
    // 判断文件夹是否存在，如果不存在，则创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        
        
    }
    
    //3.创建写数据的文件句柄
    self.writeHandle=[NSFileHandle fileHandleForWritingAtPath:filePath];
    
    //4.获取完整的文件长度
    self.sumLength=response.expectedContentLength;
}

/*
 *当接收到服务器的数据时会调用（可能会被调用多次，每次只传递部分数据）
 */
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //累加接收到的数据长度
    self.currentLength+=data.length;
    //计算进度值
    
    //一点一点接收数据。
    //把data写入到创建的空文件中，但是不能使用writeTofile(会覆盖)
    //移动到文件的尾部
    [self.writeHandle seekToEndOfFile];
    //从当前移动的位置，写入数据
    [self.writeHandle writeData:data];
    
    //NSLog(@"接收到服务器的数据！---%@",data);
}

/*
 *当服务器的数据加载完毕时就会调用
 */
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    //关闭连接，不再输入数据在文件中
    [self.writeHandle closeFile];
    
    //清空进度值
    self.currentLength=0;
    self.sumLength=0;
    
    if([self.delegate respondsToSelector:@selector(DownloadOver)])
    {
        [self.delegate DownloadOver];
    }
    
}



/*
 *请求错误（失败）的时候调用（请求超时\断网\没有网\，一般指客户端错误）
 */
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    
    if([self.delegate respondsToSelector:@selector(DownloadBreak)])
    {
        [self.delegate DownloadBreak];
    }
}

/**
 删除文件
 */
-(void)deleteFile{
    NSString *documentsPath =[self getDocumentsPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *iOSPath = [documentsPath stringByAppendingPathComponent:Downloadfile];
    BOOL isSuccess = [fileManager removeItemAtPath:iOSPath error:nil];
    if (isSuccess) {
        NSLog(@"delete success");
    }else{
        NSLog(@"delete fail");
    }
}

- (NSString *)getDocumentsPath
{
    //获取Documents路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    return path;
}

-(BOOL) isFileExist:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:filePath];
    NSLog(@"这个文件已经存在：%@",result?@"是的":@"不存在");
    return result;
}

/**
 *  下载文件
 *
 *  @param downloadURL  下载链接
 *  @param success 请求结果
 *  @param faliure 错误信息
 */
+(void)downloadURL:(NSString *) downloadURL progress:(void (^)(NSProgress *downloadProgress))progress destination:(void (^)(NSURL *targetPath))destination failure:(void(^)(NSError *error))faliure{
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [path stringByAppendingPathComponent:Downloadfile];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:filePath];
        if (result) {
            BOOL isSuccess = [fileManager removeItemAtPath:filePath error:nil];
            if (isSuccess) {
                NSLog(@"delete success");
            }else{
                NSLog(@"delete fail");
            }
        }
    
    //1.创建管理者
    AFHTTPSessionManager *manage  = [QFTools sharedManager];
    
    //2.下载文件
    /*
     第一个参数：请求对象
     第二个参数：下载进度
     第三个参数：block回调，需要返回一个url地址，用来告诉AFN下载文件的目标地址
     targetPath：AFN内部下载文件存储的地址，tmp文件夹下
     response：请求的响应头
     返回值：文件应该剪切到什么地方
     第四个参数：block回调，当文件下载完成之后调用
     response：响应头
     filePath：文件存储在沙盒的地址 == 第三个参数中block的返回值
     error：错误信息
     */
    
    //2.1 创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString: downloadURL]];
    
    NSURLSessionDownloadTask *downloadTask = [manage downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {//进度
        
        if (downloadProgress) {
            progress(downloadProgress);
        }
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        //拼接文件全路径
        NSString *fullpath = [caches stringByAppendingPathComponent:Downloadfile];
        NSURL *filePathUrl = [NSURL fileURLWithPath:fullpath];
        NSLog(@"文件路劲%@",response.suggestedFilename);
        //[dataArr writeToFile:filePath atomically:YES];
        return filePathUrl;
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath, NSError * _Nonnull error) {
        
        
        if (error) {
            faliure(error);
        }
        
        
        if(filePath){
            
            destination(filePath);
        }
    }];
    
    //3.启动任务
    [downloadTask resume];
}

@end

//
//  LVFmdbTool.m
//  LVDatabaseDemo
//
//
//  Copyright (c) 2015年 liuchunlao. All rights reserved.
//

#import "LVFmdbTool.h"


#define LVSQLITE_NAME @"modals.sqlite"

@implementation LVFmdbTool


static FMDatabase *_fmdb;

+ (void)initialize {
    // 执行打开数据库和创建表操作
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:LVSQLITE_NAME];
    _fmdb = [FMDatabase databaseWithPath:filePath];
    
    [_fmdb open];
    
 //#warning 必须先打开数据库才能创建表。。。否则提示数据库没有打开
    
    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS bike_modals(id INTEGER PRIMARY KEY, bikeid INTEGER NOT NULL,bikename TEXT,ownerflag INTEGER,ecu_id TEXT,hwversion TEXT,firmversion TEXT,keyversion TEXT,mac TEXT,sn TEXT,mainpass TEXT ,password TEXT, bindedcount INTEGER,ownerphone TEXT, fp_func INTEGER,fp_conf_count INTEGER,tpm_func INTEGER,gps_func INTEGER, vibr_sens_func INTEGER, wheels INTEGER,builtin_gps INTEGER );"];
    
    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS brand_modals(id INTEGER PRIMARY KEY,bikeid INTEGER NOT NULL,brandid INTEGER,brandname TEXT,logo TEXT,bike_pic TEXT);"];
    
    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS key_modals(id INTEGER PRIMARY KEY,keyid INTEGER NOT NULL,keyname TEXT,sn TEXT,deviceid INTEGER);"];
    
    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS info_modals(id INTEGER PRIMARY KEY,bikeid INTEGER NOT NULL,modelid INTEGER, modelname TEXT ,batttype INTEGER ,battvol INTEGER,wheelsize INTEGER ,brandid INTEGER , pictures TEXT,pictureb TEXT);"];
    
    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS fingerprint_modals(id INTEGER PRIMARY KEY,bikeid INTEGER NOT NULL,fp_id INTEGER,pos INTEGER, name TEXT ,added_time INTEGER);"];
    
    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS periphera_modals(id INTEGER PRIMARY KEY,bikeid INTEGER NOT NULL,deviceid INTEGER,type INTEGER,seq INTEGER,mac TEXT ,sn TEXT,firmversion TEXT,qr TEXT,default_brand_id INTEGER,default_model_id INTEGER,prod_date TEXT,imei TEXT,imsi TEXT,sign TEXT,desc TEXT,ts INTEGER,bind_sn TEXT ,bind_mac TEXT,is_used INTEGER);"];
    
    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS peripheraServicesInfo_modals(id INTEGER PRIMARY KEY,bikeid INTEGER NOT NULL,deviceid INTEGER,ServiceID INTEGER,type INTEGER,title TEXT ,brand_id INTEGER,begin_date TEXT,end_date TEXT,left_days INTEGER);"];
    
    /*手机感应表*/
    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS induction_modals(id INTEGER PRIMARY KEY,bikeid INTEGER NOT NULL,inductionValue INTEGER,induction INTEGER);"];
    /*绑定报警器UUID表*/
    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS peripherauuid_modals(id INTEGER PRIMARY KEY,username TEXT NOT NULL,bikeid INTEGER,mac TEXT,uuid TEXT);"];
    /*配件感应数值表*/
    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS induckey_modals(id INTEGER PRIMARY KEY,bikeid INTEGER NOT NULL,induckeyValue INTEGER);"];
    /*自动锁车表*/
    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS automaticlock_models(id INTEGER PRIMARY KEY,bikeid INTEGER NOT NULL,automaticlock INTEGER);"];
    /*胎压监测开启否表*/
    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS pressurelock_models(id INTEGER PRIMARY KEY,bikeid INTEGER NOT NULL,pressurelock INTEGER,speeding_alarm INTEGER);"];
    
    /*jpush推送数据表*/
    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS JPushData_models(id INTEGER PRIMARY KEY,bikeid INTEGER NOT NULL,userid INTEGER,type INTEGER,title TEXT,content TEXT,category INTEGER,time TEXT);"];
    
    /*外设（GPS）激活状态数据表*/
    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS peripheralActivationStatus_models(id INTEGER PRIMARY KEY,bikeid INTEGER NOT NULL,deviceid INTEGER,type INTEGER,activationStatus INTEGER);"];
    
    NSArray *bikeFieldAry = [NSArray arrayWithObjects:@"keyversion",@"ownerphone",@"fp_func",@"vibr_sens_func",@"tpm_func",@"fp_conf_count",@"wheels",@"sn",@"builtin_gps",@"gps_func",@"ecu_id", nil];
    for (NSString *name in bikeFieldAry) {
        if (![_fmdb columnExists:name inTableWithName:@"bike_modals"]){
            NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",@"bike_modals",name];
            [_fmdb executeUpdate:alertStr];
        }
    }
    
    NSArray *deviceFieldAry = [NSArray arrayWithObjects:@"qr",@"default_brand_id",@"default_model_id",@"prod_date",@"imei",@"imsi",@"sign",@"desc",@"ts",@"bind_sn",@"bind_mac",@"is_used",nil];
    for (NSString *name in deviceFieldAry) {
        if (![_fmdb columnExists:name inTableWithName:@"periphera_modals"]){
            NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",@"periphera_modals",name];
            [_fmdb executeUpdate:alertStr];
        }
    }
    
//    NSArray *deleteDeviceFieldAry = [NSArray arrayWithObjects:@"begin_date",@"end_date",@"left_days", nil];
//    for (NSString *name in deleteDeviceFieldAry) {
//        if ([_fmdb columnExists:name inTableWithName:@"periphera_modals"]){
//            NSString *alertStr = [NSString stringWithFormat:@"delete from periphera_modals where %@",name];
//            [_fmdb executeUpdate:alertStr];
//        }
//    }
    
    //@"begin_date",@"end_date",@"left_days"
    NSArray *brandFieldAry = [NSArray arrayWithObjects:@"bike_pic", nil];
    for (NSString *name in brandFieldAry) {
        if (![_fmdb columnExists:name inTableWithName:@"brand_modals"]){
            NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",@"brand_modals",name];
            [_fmdb executeUpdate:alertStr];
        }
    }
    
    NSArray *pressurelockFieldAry = [NSArray arrayWithObjects:@"speeding_alarm", nil];
    for (NSString *name in pressurelockFieldAry) {
        if (![_fmdb columnExists:name inTableWithName:@"pressurelock_models"]){
            NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",@"pressurelock_models",name];
            [_fmdb executeUpdate:alertStr];
        }
    }
    
    NSArray *JPushDataFieldAry = [NSArray arrayWithObjects:@"time", nil];
    for (NSString *name in JPushDataFieldAry) {
        if (![_fmdb columnExists:name inTableWithName:@"JPushData_models"]){
            NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",@"JPushData_models",name];
            [_fmdb executeUpdate:alertStr];
        }
    }
}

+ (BOOL)insertBikeModel:(BikeModel *)model{
    
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO bike_modals(bikeid,bikename, ownerflag,ecu_id, hwversion,firmversion,keyversion,mac,sn,mainpass,password,bindedcount,ownerphone,fp_func,fp_conf_count,tpm_func,gps_func,vibr_sens_func,wheels,builtin_gps) VALUES ('%zd','%@','%zd','%zd','%@','%@','%@','%@', '%@','%@','%@', '%zd','%@', '%zd', '%zd','%zd','%zd','%zd','%zd','%zd');", model.bikeid,model.bikename, model.ownerflag,model.ecu_id, model.hwversion,model.firmversion,model.keyversion,model.mac,model.sn,model.mainpass,model.password,model.bindedcount,model.ownerphone,model.fp_func,model.fp_conf_count,model.tpm_func,model.gps_func,model.vibr_sens_func,model.wheels,model.builtin_gps];
    
    return [_fmdb executeUpdate:insertSql];

    return YES;
}

+ (BOOL)insertKeyModel:(KeyModel *)model{

        NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO key_modals(keyid,keyname,sn,deviceid) VALUES ('%zd','%@','%@','%zd');", model.keyid,model.keyname,model.sn,model.deviceid];
        return [_fmdb executeUpdate:insertSql];
    
    return YES;

}

+ (BOOL)insertBrandModel:(BrandModel *)model{

    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO brand_modals(bikeid,brandid,brandname,logo,bike_pic) VALUES ('%zd','%zd','%@','%@','%@');", model.bikeid,model.brandid,model.brandname,model.logo,model.bike_pic];
    return [_fmdb executeUpdate:insertSql];
    
    return YES;

}

+ (BOOL)insertModelInfo:(ModelInfo *)model{
    
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO info_modals(bikeid,modelid, modelname, batttype,battvol,wheelsize,brandid,pictures,pictureb) VALUES ('%zd','%zd','%@','%zd','%zd','%zd','%zd','%@', '%@');", model.bikeid,model.modelid, model.modelname, model.batttype,model.battvol,model.wheelsize,model.brandid,model.pictures,model.pictureb];
    
    return [_fmdb executeUpdate:insertSql];
    
    return YES;
}

+ (BOOL)insertFingerprintModel:(FingerprintModel *)model{
    
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO fingerprint_modals(bikeid,fp_id,pos, name, added_time) VALUES ('%zd','%zd','%zd','%@','%zd');", model.bikeid,model.fp_id,model.pos, model.name, model.added_time];
    
    return [_fmdb executeUpdate:insertSql];
    return YES;
}

+ (BOOL)insertDeviceModel:(PeripheralModel *)model{


    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO periphera_modals(bikeid,deviceid, type,seq, mac,sn,qr,firmversion,default_brand_id,default_model_id,prod_date,imei,imsi,sign,desc,ts,bind_sn,bind_mac,is_used) VALUES ('%zd','%zd','%zd','%zd','%@','%@','%@','%@','%zd','%zd','%@','%@','%@','%@','%@','%zd','%@','%@','%zd');", model.bikeid,model.deviceid, model.type,model.seq, model.mac,model.sn,model.qr,model.firmversion,model.default_brand_id,model.default_model_id,model.prod_date,model.imei,model.imsi,model.sign,model.desc,model.ts,model.bind_sn,model.bind_mac,model.is_used];
    
    return [_fmdb executeUpdate:insertSql];
    
    return YES;

}

+ (BOOL)insertInductionModel:(InductionModel *)model{

    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO induction_modals(bikeid,inductionValue, induction) VALUES ('%zd','%zd','%zd');", model.bikeid,model.inductionValue, model.induction];
    
    return [_fmdb executeUpdate:insertSql];
    
    return YES;
}

+ (BOOL)insertInduckeyModel:(InduckeyModel *)model{
    
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO induckey_modals(bikeid,induckeyValue) VALUES ('%zd','%zd');", model.bikeid,model.induckeyValue];
    
    return [_fmdb executeUpdate:insertSql];
    
    return YES;
}

+ (BOOL)insertPeripheralUUIDModel:(PeripheralUUIDModel *)model{
    
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO peripherauuid_modals(username,bikeid,mac, uuid) VALUES ('%@','%zd','%@','%@');", model.username,model.bikeid, model.mac, model.uuid];
    
    return [_fmdb executeUpdate:insertSql];
    
    return YES;
}

+ (BOOL)insertAutomaticLockModel:(AutomaticLockModel *)model{
    
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO automaticlock_models(bikeid,automaticlock) VALUES ('%zd','%zd');", model.bikeid,model.automaticlock];
    
    return [_fmdb executeUpdate:insertSql];
    
    return YES;
}

+ (BOOL)insertPressureLockModel:(PressureLockModel *)model{
    
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO pressurelock_models(bikeid,pressurelock,speeding_alarm) VALUES ('%zd','%zd','%zd');", model.bikeid,model.pressurelock,model.speeding_alarm];
    
    return [_fmdb executeUpdate:insertSql];
    return YES;
}

+ (BOOL)insertJPushDataModel:(JPushDataModel *)model{
    
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO JPushData_models(bikeid,userid,type,title,content,category,time) VALUES ('%zd','%zd','%zd','%@','%@','%zd','%@');",model.bikeid,model.userid,model.type,model.title,model.content,model.category,model.time];
    
    return [_fmdb executeUpdate:insertSql];
    return YES;
}

+ (BOOL)insertPerpheraServicesInfoModel:(PerpheraServicesInfoModel *)model{
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO peripheraServicesInfo_modals(bikeid,deviceid,ServiceID,type,title,brand_id,begin_date,end_date,left_days) VALUES ('%zd','%zd','%zd','%zd','%@','%zd','%@','%@','%zd');",model.bikeid,model.deviceid,model.ID,model.type,model.title,model.brand_id,model.begin_date,model.end_date,model.left_days];
    
    return [_fmdb executeUpdate:insertSql];
    return YES;
}

+ (BOOL)insertPeripheralActivationStatusModel:(PeripheralActivationStatusModel *)model{
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO peripheralActivationStatus_models(bikeid,deviceid,type,activationStatus) VALUES ('%zd','%zd','%zd','%zd');",model.bikeid,model.deviceid,model.type,model.activationStatus];
    
    return [_fmdb executeUpdate:insertSql];
    return YES;
}

+ (NSMutableArray *)queryBikeData:(NSString *)querySql {
    
    if (querySql == nil) {
        querySql = @"SELECT * FROM bike_modals;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSInteger bikeid = [set intForColumn:@"bikeid"];
        NSString *bikename = [set stringForColumn:@"bikename"];
        NSInteger ownerflag = [set intForColumn:@"ownerflag"];
        NSInteger ecu_id = [set intForColumn:@"ecu_id"];
        NSString *hwversion = [set stringForColumn:@"hwversion"];
        NSString *firmversion = [set stringForColumn:@"firmversion"];
        NSString *keyversion = [set stringForColumn:@"keyversion"];
        NSString *mac = [set stringForColumn:@"mac"];
        NSString *sn = [set stringForColumn:@"sn"];
        NSString *password = [set stringForColumn:@"password"];
        NSString *mainpass = [set stringForColumn:@"mainpass"];
        NSInteger bindedcount = [set intForColumn:@"bindedcount"];
        NSString *ownerphone = [set stringForColumn:@"ownerphone"];
        NSInteger fp_func = [set intForColumn:@"fp_func"];
        NSInteger fp_conf_count = [set intForColumn:@"fp_conf_count"];
        NSInteger tpm_func = [set intForColumn:@"tpm_func"];
        NSInteger gps_func = [set intForColumn:@"gps_func"];
        NSInteger vibr_sens_func = [set intForColumn:@"vibr_sens_func"];
        NSInteger wheels = [set intForColumn:@"wheels"];
        NSInteger builtin_gps = [set intForColumn:@"builtin_gps"];
        BikeModel *modal = [BikeModel modalWith:bikeid bikename:bikename ownerflag:ownerflag ecu_id:ecu_id hwversion:hwversion firmversion:firmversion keyversion:keyversion mac:mac sn:sn mainpass:mainpass password:password bindedcount:bindedcount ownerphone:ownerphone fp_func:fp_func fp_conf_count:fp_conf_count tpm_func:tpm_func gps_func:gps_func vibr_sens_func:vibr_sens_func wheels:wheels builtin_gps:builtin_gps];
        [arrM addObject:modal];
    }
    return arrM;
}

+ (NSMutableArray *)queryBrandData:(NSString *)querySql{
    
    if (querySql == nil) {
        querySql = @"SELECT * FROM brand_modals;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSString *bikeid = [set stringForColumn:@"bikeid"];
        NSString *brandid = [set stringForColumn:@"brandid"];
        NSString *brandname = [set stringForColumn:@"brandname"];
        NSString *logo = [set stringForColumn:@"logo"];
        NSString *bike_pic = [set stringForColumn:@"bike_pic"];
        BrandModel *modal = [BrandModel modalWith:bikeid.intValue brandid:brandid.intValue brandname:brandname logo:logo bike_pic:bike_pic];
        [arrM addObject:modal];
    }
    return arrM;
}


+ (NSMutableArray *)queryKeyData:(NSString *)querySql{

    if (querySql == nil) {
        querySql = @"SELECT * FROM key_modals;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSString *keyid = [set stringForColumn:@"keyid"];
        NSString *keyname = [set stringForColumn:@"keyname"];
        NSString *sn = [set stringForColumn:@"sn"];
        NSString *deviceid = [set stringForColumn:@"deviceid"];
        
        KeyModel *modal = [KeyModel modalWith:keyid.intValue keyname:keyname sn:sn deviceid:deviceid.intValue];
        [arrM addObject:modal];
    }
    return arrM;
}

+ (NSMutableArray *)queryModelData:(NSString *)querySql{
    
    if (querySql == nil) {
        
        querySql = @"SELECT * FROM info_modals;";
    }

    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSInteger bikeid = [set intForColumn:@"bikeid"];
        NSInteger modelid = [set intForColumn:@"modelid"];
        NSString *modelname = [set stringForColumn:@"modelname"];
        NSInteger batttype = [set intForColumn:@"batttype"];
        NSInteger battvol = [set intForColumn:@"battvol"];
        NSInteger wheelsize = [set intForColumn:@"wheelsize"];
        NSInteger brandid = [set intForColumn:@"brandid"];
        NSString *pictures = [set stringForColumn:@"pictures"];
        NSString *pictureb = [set stringForColumn:@"pictureb"];
        
        ModelInfo *modal = [ModelInfo modalWith:bikeid modelid:modelid modelname:modelname batttype:batttype battvol:battvol wheelsize:wheelsize brandid:brandid pictures:pictures pictureb:pictureb];
        [arrM addObject:modal];
    }
    return arrM;
}

//bikeid,deviceid, type, mac,sn
+ (NSMutableArray *)queryPeripheraData:(NSString *)querySql{
    
    if (querySql == nil) {
        querySql = @"SELECT * FROM periphera_modals;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSInteger bikeid = [set intForColumn:@"bikeid"];
        NSInteger deviceid = [set intForColumn:@"deviceid"];
        NSString *type = [set stringForColumn:@"type"];
        NSString *seq = [set stringForColumn:@"seq"];
        NSString *mac = [set stringForColumn:@"mac"];
        NSString *sn = [set stringForColumn:@"sn"];
        NSString *qr = [set stringForColumn:@"qr"];
        NSString *firmversion = [set stringForColumn:@"firmversion"];
        NSInteger default_brand_id = [set intForColumn:@"default_brand_id"];
        NSInteger default_model_id = [set intForColumn:@"default_model_id"];
        NSString *prod_date = [set stringForColumn:@"prod_date"];
        NSString *imei = [set stringForColumn:@"imei"];
        NSString *imsi = [set stringForColumn:@"imsi"];
        NSString *sign = [set stringForColumn:@"sign"];
        NSString *desc = [set stringForColumn:@"desc"];
        NSInteger ts = [set intForColumn:@"ts"];
        NSString *bind_sn = [set stringForColumn:@"bind_sn"];
        NSString *bind_mac = [set stringForColumn:@"bind_mac"];
        NSInteger is_used = [set intForColumn:@"is_used"];
        PeripheralModel *modal = [PeripheralModel modalWith:bikeid deviceid:deviceid type:type.intValue seq:seq.intValue mac:mac sn:sn qr:qr firmversion:firmversion default_brand_id:default_brand_id default_model_id:default_model_id prod_date:prod_date imei:imei imsi:imsi sign:sign desc:desc ts:ts bind_sn:bind_sn bind_mac:bind_mac is_used:is_used];
        [arrM addObject:modal];
    }
    return arrM;
}

+ (NSMutableArray *)queryFingerprintData:(NSString *)querySql{
    
    if (querySql == nil) {
        querySql = @"SELECT * FROM fingerprint_modals;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSInteger bikeid = [set intForColumn:@"bikeid"];
        NSInteger fp_id = [set intForColumn:@"fp_id"];
        NSInteger pos = [set intForColumn:@"pos"];
        NSString *name = [set stringForColumn:@"name"];
        NSString * added_time = [set stringForColumn:@"added_time"];
        
        FingerprintModel *modal = [FingerprintModel modalWith:bikeid fp_id:fp_id pos:pos name:name added_time:added_time.integerValue];
        [arrM addObject:modal];
    }
    return arrM;
}

+ (NSMutableArray *)queryInductionData:(NSString *)querySql{
    
    if (querySql == nil) {
        querySql = @"SELECT * FROM induction_modals;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSInteger bikeid = [set intForColumn:@"bikeid"];
        NSInteger inductionValue = [set intForColumn:@"inductionValue"];
        NSInteger induction = [set intForColumn:@"induction"];
        
        InductionModel *modal = [InductionModel modalWith:bikeid inductionValue:inductionValue induction:induction];
        [arrM addObject:modal];
    }
    return arrM;
}

+ (NSMutableArray *)queryInduckeyData:(NSString *)querySql{
    
    if (querySql == nil) {
        querySql = @"SELECT * FROM induckey_modals;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSInteger bikeid = [set intForColumn:@"bikeid"];
        NSInteger induckeyValue = [set intForColumn:@"induckeyValue"];
        
        InduckeyModel *modal = [InduckeyModel modalWith:bikeid induckeyValue:induckeyValue];
        [arrM addObject:modal];
    }
    return arrM;
}


+ (NSMutableArray *)queryPeripheraUUIDData:(NSString *)querySql{
    
    if (querySql == nil) {
        querySql = @"SELECT * FROM peripherauuid_modals;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSString *username = [set stringForColumn:@"username"];
        NSInteger bikeid = [set intForColumn:@"bikeid"];
        NSString *mac = [set stringForColumn:@"mac"];
        NSString *uuid = [set stringForColumn:@"uuid"];
        
        PeripheralUUIDModel *modal = [PeripheralUUIDModel modalWith:username bikeid:bikeid mac:mac uuid:uuid];
        [arrM addObject:modal];
    }
    return arrM;
}

+ (NSMutableArray *)queryAutomaticLockData:(NSString *)querySql{
    
    if (querySql == nil) {
        querySql = @"SELECT * FROM automaticlock_models;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSInteger bikeid = [set intForColumn:@"bikeid"];
        NSInteger automaticlock = [set intForColumn:@"automaticlock"];
        
        AutomaticLockModel *modal = [AutomaticLockModel modalWith:bikeid automaticlock:automaticlock];
        [arrM addObject:modal];
    }
    return arrM;
}

+ (NSMutableArray *)queryPressureLockData:(NSString *)querySql{
    
    if (querySql == nil) {
        querySql = @"SELECT * FROM pressurelock_models;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSInteger bikeid = [set intForColumn:@"bikeid"];
        NSInteger pressurelock = [set intForColumn:@"pressurelock"];
        NSInteger speeding_alarm = [set intForColumn:@"speeding_alarm"];
        PressureLockModel *modal = [PressureLockModel modalWith:bikeid pressureLock:pressurelock speeding_alarm:speeding_alarm];
        [arrM addObject:modal];
    }
    return arrM;
}

+ (NSMutableArray *)queryJPushData:(NSString *)querySql{
    if (querySql == nil) {
        querySql = @"SELECT * FROM JPushData_models;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSInteger bikeid = [set intForColumn:@"bikeid"];
        NSInteger userid = [set intForColumn:@"userid"];
        NSInteger type = [set intForColumn:@"type"];
        NSString *title = [set stringForColumn:@"title"];
        NSString *content = [set stringForColumn:@"content"];
        NSInteger category = [set intForColumn:@"category"];
        NSString *time = [set stringForColumn:@"time"];
        JPushDataModel *model = [JPushDataModel modalWith:bikeid userid:userid type:type title:title content:content category:category time:time];
        [arrM addObject:model];
    }
    return arrM;
}

+ (NSMutableArray *)queryPerpheraServicesInfoData:(NSString *)querySql{
    if (querySql == nil) {
        querySql = @"SELECT * FROM peripheraServicesInfo_modals;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSInteger bikeid = [set intForColumn:@"bikeid"];
        NSInteger deviceid = [set intForColumn:@"deviceid"];
        NSInteger ID = [set intForColumn:@"ServiceID"];
        NSInteger type = [set intForColumn:@"type"];
        NSString *title = [set stringForColumn:@"title"];
        NSInteger brand_id = [set intForColumn:@"brand_id"];
        NSString *begin_date = [set stringForColumn:@"begin_date"];
        NSString *end_date = [set stringForColumn:@"end_date"];
        NSInteger left_days = [set intForColumn:@"left_days"];
        PerpheraServicesInfoModel *model = [PerpheraServicesInfoModel modelWith:bikeid deviceid:deviceid ID:ID type:type title:title brand_id:brand_id begin_date:begin_date end_date:end_date left_days:left_days];
        [arrM addObject:model];
    }
    return arrM;
}

+ (NSMutableArray *)queryPeripheralActivationStatusData:(NSString *)querySql{
    if (querySql == nil) {
        querySql = @"SELECT * FROM peripheralActivationStatus_models;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSInteger bikeid = [set intForColumn:@"bikeid"];
        NSInteger deviceid = [set intForColumn:@"deviceid"];
        NSInteger type = [set intForColumn:@"type"];
        NSInteger activationStatus = [set intForColumn:@"activationStatus"];
        PeripheralActivationStatusModel *model = [PeripheralActivationStatusModel modelWith:bikeid deviceid:deviceid type:type activationStatus:activationStatus];
        [arrM addObject:model];
    }
    return arrM;
}

+ (BOOL)deleteBikeData:(NSString *)deleteSql {
    
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM bike_modals";
    }
    
    return [_fmdb executeUpdate:deleteSql];

}

+ (BOOL)deleteKeyData:(NSString *)deleteSql {
    
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM key_modals";
    }
    
    return [_fmdb executeUpdate:deleteSql];
    
}

+ (BOOL)deleteBrandData:(NSString *)deleteSql {
    
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM brand_modals";
    }
    
    return [_fmdb executeUpdate:deleteSql];
    
}

+ (BOOL)deleteModelData:(NSString *)deleteSql {
    
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM info_modals";
    }
    
    return [_fmdb executeUpdate:deleteSql];
    
}

+ (BOOL)deleteFingerprintData:(NSString *)deleteSql{
    
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM fingerprint_modals";
    }
    
    return [_fmdb executeUpdate:deleteSql];
}

+ (BOOL)deletePeripheraData:(NSString *)deleteSql {
    
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM periphera_modals";
    }
    
    return [_fmdb executeUpdate:deleteSql];
    
}

+ (BOOL)deleteInductionData:(NSString *)deleteSql {
    
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM induction_modals";
    }
    
    return [_fmdb executeUpdate:deleteSql];
    
}

+ (BOOL)deleteInduckeyData:(NSString *)deleteSql {
    
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM induckey_modals";
    }
    
    return [_fmdb executeUpdate:deleteSql];
    
}

+ (BOOL)deletePeripheraUUIDData:(NSString *)deleteSql {
    
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM peripherauuid_modals";
    }
    
    return [_fmdb executeUpdate:deleteSql];
}


+ (BOOL)deleteAutomaticLockData:(NSString *)deleteSql {
    
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM automaticlock_models";
    }
    
    return [_fmdb executeUpdate:deleteSql];
}

+ (BOOL)deletePressureLockData:(NSString *)deleteSql {
    
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM pressurelock_models";
    }
    
    return [_fmdb executeUpdate:deleteSql];
}

+ (BOOL)deleteJPushData:(NSString *)deleteSql{
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM JPushData_models";
    }
    
    return [_fmdb executeUpdate:deleteSql];
}

+ (BOOL)deletePerpheraServicesInfoData:(NSString *)deleteSql{
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM peripheraServicesInfo_modals";
    }
    
    return [_fmdb executeUpdate:deleteSql];
}

+ (BOOL)deletePeripheralActivationStatusData:(NSString *)deleteSql{
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM peripheralActivationStatus_models";
    }
    
    return [_fmdb executeUpdate:deleteSql];
}

+ (BOOL)modifyData:(NSString *)modifySql {
    
    if (modifySql == nil) {
        modifySql = @"UPDATE base_modals SET ID_No = '789789' WHERE name = 'lisi'";
    }
    return [_fmdb executeUpdate:modifySql];
}


+ (BOOL)modifyPData:(NSString *)modifySql {
    
    if (modifySql == nil) {
        modifySql = @"UPDATE bike_modals SET stand = '789789' WHERE name = 'lisi'";
    }
    return [_fmdb executeUpdate:modifySql];
}

+ (BOOL)deleteSpecifiedData:(NSInteger)bikeid{
    BOOL one,two,three,four,five,six,seven,eight,night,ten,eleven,twelve;
    if (bikeid == 0) {
        
        one =  [_fmdb executeUpdate:@"DELETE FROM bike_modals"];
        two =  [_fmdb executeUpdate:@"DELETE FROM brand_modals"];
        three =  [_fmdb executeUpdate:@"DELETE FROM info_modals"];
        four =  [_fmdb executeUpdate:@"DELETE FROM periphera_modals"];
        five =  [_fmdb executeUpdate:@"DELETE FROM fingerprint_modals"];
        six =  [_fmdb executeUpdate:@"DELETE FROM peripherauuid_modals"];
        seven =  [_fmdb executeUpdate:@"DELETE FROM induction_modals"];
        eight =  [_fmdb executeUpdate:@"DELETE FROM induckey_modals"];
        night =  [_fmdb executeUpdate:@"DELETE FROM automaticlock_models"];
        ten =  [_fmdb executeUpdate:@"DELETE FROM JPushData_models"];
        eleven =  [_fmdb executeUpdate:@"DELETE FROM peripheraServicesInfo_modals"];
        twelve =  [_fmdb executeUpdate:@"DELETE FROM peripheralActivationStatus_models"];
        return (one & two & three & four & five & six & seven & eight & night & ten & eleven & twelve);
    }else{
        
        one =  [_fmdb executeUpdate:[NSString stringWithFormat:@"DELETE FROM bike_modals WHERE bikeid LIKE '%zd'", bikeid]];
        two =  [_fmdb executeUpdate:[NSString stringWithFormat:@"DELETE FROM brand_modals WHERE bikeid LIKE '%zd'", bikeid]];
        three =  [_fmdb executeUpdate:[NSString stringWithFormat:@"DELETE FROM info_modals WHERE bikeid LIKE '%zd'", bikeid]];
        four =  [_fmdb executeUpdate:[NSString stringWithFormat:@"DELETE FROM periphera_modals WHERE bikeid LIKE '%zd'", bikeid]];
        five =  [_fmdb executeUpdate:[NSString stringWithFormat:@"DELETE FROM fingerprint_modals WHERE bikeid LIKE '%zd'", bikeid]];
        six =  [_fmdb executeUpdate:[NSString stringWithFormat:@"DELETE FROM peripherauuid_modals WHERE bikeid LIKE '%zd'", bikeid]];
        seven =  [_fmdb executeUpdate:[NSString stringWithFormat:@"DELETE FROM induction_modals WHERE bikeid LIKE '%zd'", bikeid]];
        eight =  [_fmdb executeUpdate:[NSString stringWithFormat:@"DELETE FROM induckey_modals WHERE bikeid LIKE '%zd'", bikeid]];
        night =  [_fmdb executeUpdate:[NSString stringWithFormat:@"DELETE FROM automaticlock_models WHERE bikeid LIKE '%zd'", bikeid]];
        ten =  [_fmdb executeUpdate:[NSString stringWithFormat:@"DELETE FROM JPushData_models WHERE bikeid LIKE '%zd'", bikeid]];
        eleven =  [_fmdb executeUpdate:[NSString stringWithFormat:@"DELETE FROM peripheraServicesInfo_modals WHERE bikeid LIKE '%zd'", bikeid]];
        twelve =  [_fmdb executeUpdate:[NSString stringWithFormat:@"DELETE FROM peripheralActivationStatus_models WHERE bikeid LIKE '%zd'", bikeid]];
        return (one & two & three & four & five & six & seven & eight & night & ten & eleven & twelve);
    }
    return YES;
}

@end

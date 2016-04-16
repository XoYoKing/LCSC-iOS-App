//
//  PacketFormat.h
//  LCSC
//
//  Created by x on 4/14/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#ifndef PacketFormat_h
#define PacketFormat_h


typedef struct {
/*
 int32  RequestCode_1  //Request update
 int32  Packet Total Size
 int32  Number of month requests (how many times MonthRevision and Month Encoding repeat)
 int32  MonthRevision_1  //Note th
 int32  MonthEncoding_1
 int32  MonthRevision_2
 int32  MonthEncoding_2
 etc..
 
 */
} RequestMonthsPacketHeader;

typedef struct {
    //int32 RequestCode_2 //That's it assumes you have nothing and gets 3 months past and future
} RequestDefaultPacket;

typedef struct {
    
} ResponseMonthsHeader ;

#endif /* PacketFormat_h */

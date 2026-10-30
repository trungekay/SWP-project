package com.visioncare.util;
import java.io.*;
import javax.imageio.*;
import javax.imageio.stream.ImageInputStream;
public final class RefundImage {
 private RefundImage(){}
 public static String type(byte[] bytes)throws IOException {
  if(bytes==null||bytes.length==0||bytes.length>5*1024*1024)throw new IllegalArgumentException("Ảnh phải là PNG/JPEG và tối đa 5 MB.");
  try(ImageInputStream input=ImageIO.createImageInputStream(new ByteArrayInputStream(bytes))){
   var readers=ImageIO.getImageReaders(input);if(!readers.hasNext())throw new IllegalArgumentException("Nội dung ảnh không hợp lệ.");
   var reader=readers.next();try{reader.setInput(input);String format=reader.getFormatName();
    if(!format.equalsIgnoreCase("png")&&!format.equalsIgnoreCase("jpeg"))throw new IllegalArgumentException("Chỉ nhận ảnh PNG/JPEG.");
    int w=reader.getWidth(0),h=reader.getHeight(0);if(w<=0||h<=0||w>8000||h>8000||(long)w*h>20000000)throw new IllegalArgumentException("Kích thước ảnh quá lớn.");
    if(reader.read(0)==null)throw new IllegalArgumentException("Không đọc được ảnh.");return format.equalsIgnoreCase("png")?"image/png":"image/jpeg";
   }finally{reader.dispose();}
  }
 }
}

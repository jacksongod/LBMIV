import java.awt.List;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Arrays;
import java.util.Collections;

import org.apache.commons.codec.binary.Hex;
import org.apache.commons.lang3.ArrayUtils;


public class Main {

    public static void main(String[] args) throws IOException {
        
            MessageDigest md;

            try {

                md = MessageDigest.getInstance("SHA-256");

            } catch (NoSuchAlgorithmException ex) {
                System.out.println(ex.getMessage());
                return;
            }
            
            byte[] ds = new byte[64];
            ds[0]= (byte) 0x80;
            for(int i=1;i<62;i++){
            	ds[i]=0;
            	
            }
            ds[62]=(byte)0x2;
            ds[63]=0;

            String password = "helowrld12354322helowrld12354322helowrld12354322helowrld12354322";
            String password2 = "dsfaskjfdl;sajkfldsajkfdsjakfdjsaklfjksafjkldsafjkdsalfjdksfdsdd";
            try {
				SHA2 inp = new SHA2("SHA-256");
				byte[] outp = inp.digest(ds);
				String aw = new String(Hex.encodeHex(outp));
				System.out.println(aw);
				
			} catch (NoSuchAlgorithmException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
            
            
          
            //da.
            
           
           
           
         //   byte[] destination = new byte[password.getBytes("UTF-8").length + ds.length];
           
         // copy ciphertext into start of destination (from pos 0, copy ciphertext.length bytes)
      //   System.arraycopy(password.getBytes("UTF-8"), 0, destination, 0, password.getBytes("UTF-8").length);

         // copy mac into end of destination (from pos ciphertext.length, copy mac.length bytes)
       //  System.arraycopy(ds, 0, destination, password.getBytes("UTF-8").length, ds.length);

         md.update(password2.getBytes("UTF-8"));
            byte[] shaDig = md.digest();
           // String str = new String(shaDig, "UTF-8");
            System.out.format("The value of i is: %d\n", password.getBytes("UTF-8").length);
            System.out.format("The value of i is: %d\n", ds.length);
           // System.out.format("The value of i is: %d\n", destination.length);
            System.out.println(Hex.encodeHex(password2.getBytes("UTF-8")));
           // System.out.println(Hex.encodeHex(password.getBytes("UTF-8")));
            byte[] d = password.getBytes("UTF-8");
            ArrayUtils.reverse(d);
            String a = new String(Hex.encodeHex(shaDig));
          //  String c = new String(Hex.encodeHex(password.getBytes("UTF-8")));
            //String d = (new StringBuilder(c).reverse().toString());
            System.out.println(a);
            System.out.println(d);
            System.out.println(Hex.encodeHex(ds));
    }

}
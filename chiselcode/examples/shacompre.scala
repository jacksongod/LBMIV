package TutorialExamples

import Chisel._
import Node._
import scala.collection.mutable.HashMap
import util.Random


class eighthash extends Bundle{
    var a = UInt (INPUT,32)
    var b = UInt (INPUT,32)
    var c = UInt (INPUT,32)
    var d = UInt (INPUT,32)
    var e = UInt (INPUT,32)
    var f = UInt (INPUT,32)
    var g = UInt (INPUT,32)
    var h = UInt (INPUT,32)
}

class digestloop extends Bundle{
    var hashout = new eighthash().flip
    var hashin = new eighthash()
    var warray = UInt (INPUT,32)
    var ckey = UInt (INPUT,32)

}



class Shacompre extends Module {
  val io = new digestloop()
  val s1 = Cat(io.hashin.e(5,0),io.hashin.e(31,6))^Cat(io.hashin.e(10,0),io.hashin.e(31,11))^Cat(io.hashin.e(24,0),io.hashin.e(31,25))
  val ch = (io.hashin.e & io.hashin.f) ^ ((~io.hashin.e)&io.hashin.g)
  val temp1 = io.hashin.h + s1 +ch +io.ckey+io.warray
  val s0 = Cat(io.hashin.a(1,0),io.hashin.a(31,2))^Cat(io.hashin.a(12,0),io.hashin.a(31,13))^Cat(io.hashin.a(21,0),io.hashin.a(31,22))
  val maj = (io.hashin.a & io.hashin.b)^ (io.hashin.a & io.hashin.c)^(io.hashin.b & io.hashin.c)
  val temp2 = s0 + maj
  
  io.hashout.h := io.hashin.g
  io.hashout.g := io.hashin.f
  io.hashout.f := io.hashin.e
  io.hashout.e := io.hashin.d + temp1
  io.hashout.d := io.hashin.c
  io.hashout.c := io.hashin.b
  io.hashout.b := io.hashin.a
  io.hashout.a := temp1 + temp2
 
  
 //Generate the sum
//  val a_xor_b = io.a ^ io.b
//  io.sum := a_xor_b ^ io.cin
  //Generate the carry
//  val a_and_b = io.a & io.b
//  val b_and_cin = io.b & io.cin
//  val a_and_cin = io.a & io.cin
//  io.cout := a_and_b | b_and_cin | a_and_cin
}

class ShacompreTests(c: Shacompre) extends Tester(c, Array(c.io)) {  
  defTests {
    var allGood = true
   // val rnd  = new Random()
    val vars = new HashMap[Node, Node]()
    //for (t <- 0 until 1) {
      vars.clear()
      val wordin    =UInt("h80000000")
      val ckeyin = UInt("h428a2f98")
      val ain = UInt("h6a09e667")
      val bin = UInt("hbb67ae85")
      val cin = UInt("h3c6ef372")
      val din = UInt("ha54ff53a")
      val ein = UInt("h510e527f")
      val fin = UInt("h9b05688c")
      val gin = UInt("h1f83d9ab")
      val hin = UInt("h5be0cd19")
      
      val aout = UInt("h7c08884d")
      val bout = UInt("h6a09e667")
      val cout = UInt("hbb67ae85")
      val dout = UInt("h3c6ef372")
      val eout = UInt("h18c7e2a2")
      val fout = UInt("h510e527f")
      val gout = UInt("h9b05688c")
      val hout = UInt("h1f83d9ab")
   // val res  = a + b + cin
     // val sum  = res & 1
     // val cout = (res >> 1) & 1
      vars(c.io.hashin.a)    = ain
      vars(c.io.hashin.b)    = bin
      vars(c.io.hashin.c)    = cin
      vars(c.io.hashin.d)    = din
      vars(c.io.hashin.e)    = ein
      vars(c.io.hashin.f)    = fin
      vars(c.io.hashin.g)    = gin
      vars(c.io.hashin.h)    = hin
     
      vars(c.io.warray) = wordin
      vars(c.io.ckey) = ckeyin
      vars(c.io.hashout.a) = aout
      vars(c.io.hashout.b) = bout
      vars(c.io.hashout.c) = cout
      vars(c.io.hashout.d) = dout
      vars(c.io.hashout.e) = eout
      vars(c.io.hashout.f) = fout
      vars(c.io.hashout.g) = gout
      vars(c.io.hashout.h) = hout

      //vars(c.io.b)    = UInt(b)
      //vars(c.io.cin)  = UInt(cin)
      //vars(c.io.sum)  = UInt(sum)
      //vars(c.io.cout) = UInt(cout)
      allGood = step(vars) && allGood
   // }
    allGood
  }
}

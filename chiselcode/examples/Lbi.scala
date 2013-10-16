package TutorialExamples

import Chisel._
import scala.collection.mutable.HashMap
import util.Random
import scala.collection.mutable.ArrayBuffer
import scala.collection.parallel.ParIterableLike
class LBio(n: Int) extends Bundle {
   val myinput = UInt(INPUT,n)
   val myoutput = UInt (OUTPUT,n)

}


class Lbi(q: Int,n:Int,m :Int ) extends Module{
   def mask(orig: Vec[UInt],maska:UInt,mi:Int)={
   val result = Vec.fill(840){UInt(width =6)}
    for (i<-0 until 840 ){
         result(i) := orig(i)&Fill(6,maska(i))
      } 
    
    //val aftermask = result.(_+_)
    // aftermask
     result
   } 
    
  val io= new LBio(840)
   //val rnd = new Random()
 //  val rndvec =  Vec.fill(140){Vec.fill(840){Reg(init = UInt("h13"))}}
   val rndvec =  Vec.fill(840){UInt("h13")}       //random vector, for now its just replication of 0x13....
   val resultvec = Vec.fill(140){UInt(width = 6)}
   val datavec = io.myinput
 // for (i<-0 until 140;j<- 0 until 840){
 //      rndvec(i)(j) := UInt("h13")
 // } 
  
  for (i<-0 until 140){ 
      val temprow = mask(rndvec,datavec,m)
       resultvec(i) := temprow.reduceLeft(_+_)//Range(0,840).map(i=>temprow(i)).reduceLeft(_+_)
      
     // io.myoutput(i) := resultvec(i)
  }
  
 io.myoutput := resultvec.reduceLeft(Cat(_,_))   
 

}



class LbiTests(c: Lbi) extends Tester(c, Array(c.io)) {
  defTests {
    var allGood = true
    val vars    = new HashMap[Node, Node]()
    val ovars   = new HashMap[Node, Node]()
    var tot     = 0
 //   vars (c.io.myinput) = UInt("h10011")
//    vars (c.io.myoutput) = UInt("h10011")
    allGood = step(vars) &&allGood
    // TODO: WRITE REAL TEST SUITE
    allGood
  }
}

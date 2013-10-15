package TutorialExamples

import Chisel._

object TutorialExamples {
  def main(args: Array[String]): Unit = {
    val tutArgs = args.slice(1, args.length)
    val res =
    args(0) match {
      case "Lbi" =>
        chiselMainTest(tutArgs, () => Module(new Lbi(6,140,840))){
          c => new LbiTests(c)}
      case "shacompre" =>
        chiselMainTest(tutArgs, () => Module(new Shacompre())){
          c => new ShacompreTests(c)}
   
    }
  }
}


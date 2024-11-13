package org.technoserve.farmcollector.database



object Operators {
    fun addTwoInt(m: Int, n: Int): Int = m + n
}


class CalculatorExample ( val operators:Operators) {
    fun addTwoNumbers(a: Int, b: Int): Int = operators.addTwoInt(a,b)
}
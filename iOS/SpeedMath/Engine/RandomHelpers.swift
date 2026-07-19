import Foundation

@inline(__always)
func rInt(_ range: ClosedRange<Int>, _ rng: inout SeededRNG) -> Int {
    Int.random(in: range, using: &rng)
}

/// A random integer, excluding zero — useful for divisors/denominators.
@inline(__always)
func rIntNonZero(_ range: ClosedRange<Int>, _ rng: inout SeededRNG) -> Int {
    var v = rInt(range, &rng)
    if v == 0 { v = 1 }
    return v
}

func gcdInt(_ a: Int, _ b: Int) -> Int {
    var a = abs(a), b = abs(b)
    while b != 0 { (a, b) = (b, a % b) }
    return max(a, 1)
}

/// A small integer scale factor derived from how far `level` sits into its
/// band, used to gently grow operand size within a band's ten levels.
func bandProgress(_ level: Int, bandStart: Int) -> Int {
    max(0, level - bandStart)
}

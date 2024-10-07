import Benchmark
import Foundation
import Parsing

/// This benchmarks the performance of `PrefixUpTo` against Apple's tools.
let prefixThroughSuite = BenchmarkSuite(name: "PrefixThrough") { suite in
  let input = String(repeating: ".", count: 10_000) + "Hello, world!"
  let marker = "Hello"

  do {
    var output: Substring!
    suite.benchmark("Parser: Substring") {
      var input = input[...]
      output = try PrefixThrough(marker).parse(&input)
    } tearDown: {
      precondition(output.count == 10_000 + marker.count)
    }
  }

  do {
    var output: Substring.UTF8View!
    suite.benchmark("Parser: UTF8") {
      var input = input[...].utf8
      output = try PrefixThrough(marker.utf8).parse(&input)
    } tearDown: {
      precondition(output.count == 10_000 + marker.count)
    }
  }

  do {
    var output: Substring!
    suite.benchmark("String.range(of:)") {
      output = input.range(of: marker).map { input.prefix(upTo: $0.upperBound) }
    } tearDown: {
      precondition(output.count == 10_000 + marker.count)
    }
  }

  if #available(macOS 10.15, *) {
    var output: String!
    let scanner = Scanner(string: input)
    suite.benchmark("Scanner.scanUpToString") {
      output = scanner.scanUpToString(marker)
      output += scanner.scanString(marker)!
    } setUp: {
      scanner.currentIndex = input.startIndex
    } tearDown: {
      precondition(output.count == 10_000 + marker.count)
    }
  }
}

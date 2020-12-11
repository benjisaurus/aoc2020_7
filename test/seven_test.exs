defmodule SevenTest do
  use ExUnit.Case
  doctest Seven

  test "parsing rules" do
    input = "dotted black bags contain no other bags."
    assert Seven.parse_line(input) == [{:color, "dotted black"}, {:contents, []}]
    input2 = "bright white bags contain 1 shiny gold bag."
    assert Seven.parse_line(input2) == [{:color, "bright white"}, {:contents, [[{:quantity, 1}, {:color, "shiny gold"}]]}]
    input3 = "dark orange bags contain 3 bright white bags, 4 muted yellow bags."
    assert Seven.parse_line(input3) == [{:color, "dark orange"}, {:contents, [[{:quantity, 3}, {:color, "bright white"}], [{:quantity, 4}, {:color, "muted yellow"}]]}]
  end

  test "Contains" do
    refute Seven.contains?("shiny gold", [{:color, "dotted black"}, {:contents, []}])
    assert Seven.contains?("shiny gold", [{:color, "bright white"}, {:contents, [[{:quantity, 1}, {:color, "shiny gold"}]]}])
    refute Seven.contains?("shiny gold", [{:color, "bright white"}, {:contents, [[{:quantity, 1}, {:color, "blah blah"}]]}])
    assert Seven.contains?("shiny gold", [{:color, "dark orange"}, {:contents, [[{:quantity, 3}, {:color, "shiny gold"}], [{:quantity, 4}, {:color, "muted yellow"}]]}])
    refute Seven.contains?("shiny gold", [{:color, "dark orange"}, {:contents, [[{:quantity, 3}, {:color, "bright white"}], [{:quantity, 4}, {:color, "muted yellow"}]]}])
  end

end

defmodule Seven do

  def get_input(filename) do
    {:ok, contents} = File.read(filename)
    String.split(contents, "\n")
  end

  def parse_bags(words), do: parse_bags(words, [])
  def parse_bags([], bags), do: bags
  def parse_bags([ num, c1, c2, _ | t ], bags) do
    content = [{:quantity, String.to_integer(num)}, {:color, c1 <> " " <> c2}]
    parse_bags(t, [ content | bags ])
  end

  def parse_line(line) do
    parts = String.split(line, " contain ")
    color = List.first(parts) |> String.split(" bags") |> List.first
    words = List.last(parts) |> String.split(" ")
    case Enum.count(words) do
      3 ->
        _res = [{:color, color},{:contents, []}]
      _ ->
        content = parse_bags(words)
        _res = [
          {:color, color},
          {:contents, content}
        ]
    end
  end

  def contains?(color, rule) do
    in_contents?(color, rule)
  end

  def in_contents?(_color, []), do: false
  def in_contents?(_color, nil), do: false
  def in_contents?(color, [{:quantity, _}, {:color, color}]), do: true
  def in_contents?(_color, [{:quantity, _}, {:color, _color2}]), do: false
  def in_contents?(color, [[{:quantity, _}, {:color, color}] | _]), do: true
  def in_contents?(color, [[{:quantity, _}, {:color, _color2}] | t ]), do: in_contents?(color, t)

  def get_rules(lines), do: get_rules([], lines)
  def get_rules(rules, []), do: rules
  def get_rules(rules, [ h | t ]) do
    case h do
      "" -> get_rules(rules, t)
      line ->
        rule = parse_line(line)
        get_rules([ rule | rules ], t)
    end
  end

  def how_many_in_file(color, filename) do
    lines = get_input(filename)
    rules = get_rules(lines)
    rule_map = rules_to_map(rules)
    how_many(color, rule_map)
  end

  def get_colors(rules), do: get_colors(rules, [])
  def get_colors([], colors), do: colors
  def get_colors([ h | t ], colors), do: get_colors(t, [ h[:color] | colors])

  def rules_to_map(rules), do: rules_to_map(rules, %{})
  def rules_to_map([], m), do: m
  def rules_to_map([ h | t], m) do
    color = h[:color]
    rule = h[:contents]
    rules_to_map(t, Map.put(m, color, rule))
  end

  def how_many(color, rule_map) do
    checked = []
    to_be_checked = Map.keys(rule_map)
    how_many(color, rule_map, checked, to_be_checked, [])
  end

  def get_colors_from_map(rules), do: get_colors_from_map(rules, [])
  def get_colors_from_map([], colors), do: colors
  def get_colors_from_map([ h | t ], colors) do
    get_colors_from_map(t, [ h[:color] | colors ])
  end


  def how_many(_color, _rule_map, _checked, [], could_contain), do: could_contain
  def how_many(color, rule_map, checked, [ h | t ], could_contain) do
    case Enum.member?(checked, h) do
      true -> how_many(color, rule_map, checked, t, could_contain)
      false -> 
        case contains?(color, rule_map[h]) do
          true -> 
            more_colors = get_colors_from_map(rule_map[h])
            secondary = how_many(h, rule_map)
            to_add = Enum.concat(could_contain, [ h |  secondary]) |> Enum.uniq()
            how_many(color, rule_map, [ h | checked ], Enum.concat(t, more_colors), to_add)
          false -> how_many(color, rule_map, [ h | checked ], t, could_contain)
        end
    end
  end

  def bag_count(color, rules), do: bag_count(color, rules, rules[color])
  def bag_count(color, rules, []), do: 0
  def bag_count(color, rules, [ [{:quantity,  q}, {:color,  c}] | t]) do
    (q + (q * bag_count(c, rules))) + bag_count(c, rules, t)
  end



end

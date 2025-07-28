defmodule LicensePlatePT.Manipulation do
  @moduledoc """
  Manipulate a license plate.
  """

  alias LicensePlatePT.Information
  alias LicensePlatePT.LicensePlate
  alias LicensePlatePT.Validation

  import LicensePlatePT,
    only: [valid?: 1, valid_partial?: 1, to_struct: 1, to_struct!: 1]

  require Logger

  @letter_lower_limit LicensePlatePT.get_letter_lower_limit()
  @letter_upper_limit LicensePlatePT.get_letter_upper_limit()

  @type123_max_number LicensePlatePT.get_type123_max_number()
  @type4_max_number LicensePlatePT.get_type4_max_number()

  @type license_plate_triplet() :: {nil | 1..4, String.t(), 0..9999}

  @doc """
  Add dash to a license plate. If an invalid license plate is provided, `nil` is returned.

  ## Examples

    iex> LicensePlatePT.add_dash("AB01DF")
    "AB-01-DF"

    iex> LicensePlatePT.add_dash("AB-01-DF")
    "AB-01-DF"

    iex> LicensePlatePT.add_dash("dsds")
    nil
  """
  def add_dash(license_plate) do
    if valid?(license_plate) || valid_partial?(license_plate) do
      case String.split(license_plate, "", trim: true) do
        [a, b, c, d, e, f] -> String.upcase("#{a}#{b}-#{c}#{d}-#{e}#{f}")
        [_, _, "-", _, _, "-", _, _] -> String.upcase(license_plate)
        _ -> nil
      end
    else
      nil
    end
  end

  @doc """
  Generate the next valid license plate.

  It supports both shorter (without dash, ex: 0054AA) or longer (width dash, ex: 00-54-AA) license plate patterns.
  """
  @spec next(nil | binary(), integer()) :: binary() | nil
  def next(license_plate, iterations \\ 1)

  def next(nil, _), do: nil

  def next(license_plate, iterations) when iterations < 0,
    do: previous(license_plate, abs(iterations))

  def next(%{plate: license_plate}, iterations), do: next(license_plate, iterations)

  def next(%{license_plate: license_plate}, iterations), do: next(license_plate, iterations)

  def next(license_plate, 0), do: license_plate

  def next(license_plate, iterations) do
    license_plate
    |> to_struct()
    |> process_next_license_plate()
    |> next(iterations - 1)
  end

  defp process_next_license_plate({:error, _}) do
    nil
  end

  defp process_next_license_plate({:ok, %LicensePlate{} = license_plate}) do
    license_plate
    |> safe_increase_numbers()
    |> case do
      {nil, _, _} ->
        nil

      {type, letters, numbers} ->
        dashes = String.contains?(to_string(license_plate), "-")
        to_string(%LicensePlate{type: type, letters: letters, numbers: numbers, dashes: dashes})
    end
  end

  @spec safe_increase_numbers(LicensePlate.t()) :: license_plate_triplet()
  defp safe_increase_numbers(%LicensePlate{
         type: type,
         letters: letters,
         numbers: numbers
       }) do
    if numbers + 1 > max_numbers(type) do
      # Avoid 00-00
      handle_upper_bound(type, letters, numbers)
    else
      {type, letters, numbers + 1}
    end
  end

  defp max_numbers(4), do: @type4_max_number
  defp max_numbers(type) when type >= 1 and type <= 3, do: @type123_max_number

  @doc """
  Get previous license plate.

  ## Examples

    iex> LicensePlatePT.previous("AA-01-01")
    "AA-01-00"

    iex> LicensePlatePT.previous("AA-01-01", 2)
    "AA-00-99"

    iex> LicensePlatePT.previous("AA-01-01", -2)
    "AA-01-03"
  """
  @spec previous(binary(), integer()) :: binary() | nil
  def previous(license_plate, iterations \\ 1)

  def previous(nil, _), do: nil

  def previous(license_plate, iterations) when iterations < 0,
    do: next(license_plate, abs(iterations))

  def previous(%{plate: license_plate}, iterations),
    do: previous(license_plate, iterations)

  def previous(%{license_plate: license_plate}, iterations),
    do: previous(license_plate, iterations)

  def previous(license_plate, 0), do: license_plate

  def previous(license_plate, iteration) do
    license_plate
    |> to_struct()
    |> process_previous_license_plate()
    |> previous(iteration - 1)
  end

  defp process_previous_license_plate({:error, _}), do: nil

  defp process_previous_license_plate({:ok, %LicensePlate{} = license_plate}) do
    license_plate
    |> safe_decrease_numbers()
    |> case do
      {nil, _, _} ->
        nil

      {new_type, new_letters, new_numbers} ->
        dashes = String.contains?(to_string(license_plate), "-")

        to_string(%LicensePlate{
          type: new_type,
          letters: new_letters,
          numbers: new_numbers,
          dashes: dashes
        })
    end
  end

  @spec safe_decrease_numbers(LicensePlate.t()) :: license_plate_triplet()
  defp safe_decrease_numbers(%LicensePlate{type: type, letters: letters, numbers: numbers}) do
    if lower_bound?(type, letters, numbers) do
      handle_lower_bound(type, letters, numbers)
    else
      {type, letters, numbers - 1}
    end
  end

  defp lower_bound?(type, letters, numbers),
    do:
      (type in [1, 2, 3] && numbers - 1 == 0) || numbers - 1 < 0 ||
        (type == 4 && letters == "AAAA" && numbers == 1)

  @spec handle_upper_bound(integer(), binary(), integer()) ::
          {integer(), binary(), integer()} | {nil, nil, nil}
  defp handle_upper_bound(type, letters, _numbers) do
    next_letters = next_letters(letters)

    cond do
      is_nil(next_letters) ->
        {nil, nil, nil}

      next_letters == "AA" ->
        new_type = type + 1

        if new_type == 4 do
          {new_type, "AAAA", 1}
        else
          {new_type, "AA", 1}
        end

      invalid_letters_jump(type, next_letters, :next) > 0 ->
        start_number = if type != 4, do: 1, else: 0

        {type, next_letters(next_letters, invalid_letters_jump(type, next_letters, :next)),
         start_number}

      true ->
        case String.length(next_letters) do
          2 -> {type, next_letters, 1}
          4 -> {type, next_letters, 0}
        end
    end
  end

  defp handle_lower_bound(type, letters, _numbers) do
    previous_letters = previous_letters(letters)

    cond do
      is_nil(previous_letters) ->
        {type - 1, "ZZ", @type123_max_number}

      previous_letters == "ZZ" and type == 1 ->
        {nil, nil, nil}

      previous_letters == "ZZ" ->
        {type - 1, "ZZ", @type123_max_number}

      invalid_letters_jump(type, previous_letters, :prev) > 0 ->
        start_number = get_start_number_on_lower_bound(type)

        {type,
         previous_letters(previous_letters, invalid_letters_jump(type, previous_letters, :prev)),
         start_number}

      true ->
        start_number = get_start_number_on_lower_bound(type)
        {type, previous_letters, start_number}
    end
  end

  defp get_start_number_on_lower_bound(4), do: @type4_max_number
  defp get_start_number_on_lower_bound(_), do: @type123_max_number

  @spec next_letters(binary() | nil, integer()) :: binary() | nil
  def next_letters(letters, iteration \\ 1)

  def next_letters(nil, _), do: nil

  def next_letters(letters, 0), do: letters

  def next_letters(letters, iteration) when byte_size(letters) == 2 do
    <<letter1_ascii::utf8, letter2_ascii::utf8>> = letters

    cond do
      letter2_ascii < @letter_upper_limit and letters == "KF" ->
        "LA"

      letter2_ascii < @letter_upper_limit ->
        increment = if Enum.member?(["W", "Y", "K"], <<letter2_ascii + 1>>), do: 2, else: 1
        <<letter1_ascii, letter2_ascii + increment>>

      letter1_ascii < @letter_upper_limit ->
        increment = if Enum.member?(["W", "Y"], <<letter1_ascii + 1>>), do: 2, else: 1
        <<letter1_ascii + increment, @letter_lower_limit>>

      true ->
        # Roll over
        <<@letter_lower_limit, @letter_lower_limit>>
    end
    |> next_letters(iteration - 1)
  end

  def next_letters("ALZZ", iteration) do
    next_letters("ANAA", iteration - 1)
  end

  def next_letters("AOZZ", iteration) do
    next_letters("AQAA", iteration - 1)
  end

  def next_letters(letters, iteration) when byte_size(letters) == 4 do
    <<letter1_ascii::utf8, letter2_ascii::utf8, letter3_ascii::utf8, letter4_ascii::utf8>> =
      letters

    cond do
      letter4_ascii < @letter_upper_limit ->
        increment = get_letter_increment(letter4_ascii)
        <<letter1_ascii, letter2_ascii, letter3_ascii, letter4_ascii + increment>>

      letter3_ascii < @letter_upper_limit ->
        increment = get_letter_increment(letter3_ascii)
        <<letter1_ascii, letter2_ascii, letter3_ascii + increment, @letter_lower_limit>>

      letter2_ascii < @letter_upper_limit ->
        increment = get_letter_increment(letter2_ascii)
        <<letter1_ascii, letter2_ascii + increment, @letter_lower_limit, @letter_lower_limit>>

      letter1_ascii < @letter_upper_limit ->
        increment = get_letter_increment(letter4_ascii)

        <<letter1_ascii + increment, @letter_lower_limit, @letter_lower_limit,
          @letter_lower_limit>>

      true ->
        nil
    end
    |> check_for_invalid_and_jump(:next)
    |> next_letters(iteration - 1)
  end

  @spec check_for_invalid_and_jump(binary() | nil, :next | :prev) :: binary() | nil
  defp check_for_invalid_and_jump(nil, _), do: nil

  defp check_for_invalid_and_jump(letters, direction) when is_binary(letters) do
    jump = invalid_letters_jump(4, letters, direction)

    cond do
      jump == 0 -> letters
      direction == :prev -> previous_letters(letters, jump)
      direction == :next -> next_letters(letters, jump)
    end
  end

  @spec previous_letters(binary() | nil, integer()) :: binary() | nil
  def previous_letters(letters, iteration \\ 1)

  def previous_letters(nil, _), do: nil

  def previous_letters(letters, 0), do: letters

  def previous_letters(letters, iteration) when byte_size(letters) == 2 do
    <<letter1_ascii::utf8, letter2_ascii::utf8>> = letters

    cond do
      letter2_ascii > @letter_lower_limit ->
        increment = if Enum.member?(["W", "Y", "K"], <<letter2_ascii - 1>>), do: 2, else: 1
        <<letter1_ascii, letter2_ascii - increment>>

      letter1_ascii > @letter_lower_limit and letters == "LA" ->
        "KF"

      letter1_ascii > @letter_lower_limit ->
        increment = if Enum.member?(["W", "Y"], <<letter1_ascii - 1>>), do: 2, else: 1
        <<letter1_ascii - increment, @letter_upper_limit>>

      true ->
        # Roll over
        <<@letter_upper_limit, @letter_upper_limit>>
    end
    |> previous_letters(iteration - 1)
  end

  def previous_letters("ANAA", iteration) do
    previous_letters("ALZZ", iteration - 1)
  end

  def previous_letters("AQAA", iteration) do
    previous_letters("AOZZ", iteration - 1)
  end

  def previous_letters(letters, iteration) when byte_size(letters) == 4 do
    <<letter1_ascii::utf8, letter2_ascii::utf8, letter3_ascii::utf8, letter4_ascii::utf8>> =
      letters

    cond do
      letter4_ascii > @letter_lower_limit ->
        decrement = get_letter_decrement(letter4_ascii)
        <<letter1_ascii, letter2_ascii, letter3_ascii, letter4_ascii - decrement>>

      letter3_ascii > @letter_lower_limit ->
        decrement = get_letter_decrement(letter3_ascii)
        <<letter1_ascii, letter2_ascii, letter3_ascii - decrement, @letter_upper_limit>>

      letter2_ascii > @letter_lower_limit ->
        decrement = get_letter_decrement(letter2_ascii)
        <<letter1_ascii, letter2_ascii - decrement, @letter_upper_limit, @letter_upper_limit>>

      letter1_ascii > @letter_lower_limit ->
        decrement = get_letter_decrement(letter1_ascii)

        <<letter1_ascii - decrement, @letter_upper_limit, @letter_upper_limit,
          @letter_upper_limit>>

      true ->
        nil
    end
    |> check_for_invalid_and_jump(:prev)
    |> previous_letters(iteration - 1)
  end

  defp get_letter_increment(letter_ascii) when is_integer(letter_ascii) do
    if Enum.member?(["K", "W", "Y"], <<letter_ascii + 1>>), do: 2, else: 1
  end

  defp get_letter_decrement(letter_ascii) when is_integer(letter_ascii) do
    if Enum.member?(["K", "W", "Y"], <<letter_ascii - 1>>), do: 2, else: 1
  end

  @doc """
  Given a partial license plate, it fills the rest of the pattern with blanks in order to
  search into the database for possible matches.

  ## Example

    iex> LicensePlatePT.Manipulation.fill_partial("2")
    {:ok, "2_-__-__"}
  """
  def fill_partial(partial_license_plate) do
    fill_partial_inner(partial_license_plate)
    |> case do
      :invalid_license_plate -> {:error, :invalid_license_plate}
      license_plate_match -> {:ok, license_plate_match}
    end
  end

  def fill_partial!(partial_license_plate) do
    case fill_partial(partial_license_plate) do
      {:ok, license_plate} -> license_plate
      {:error, message} -> raise ArgumentError, message: message
    end
  end

  defp fill_partial_inner(""), do: "__-__-__"

  defp fill_partial_inner(<<partial_license_plate::bytes-size(1)>>),
    do: "#{partial_license_plate}_-__-__"

  defp fill_partial_inner(<<partial_license_plate::bytes-size(2)>>),
    do: "#{partial_license_plate}-__-__"

  defp fill_partial_inner(<<partial_license_plate::bytes-size(3)>>),
    do: "#{partial_license_plate}__-__"

  defp fill_partial_inner(<<partial_license_plate::bytes-size(4)>>),
    do: "#{partial_license_plate}_-__"

  defp fill_partial_inner(<<partial_license_plate::bytes-size(5)>>),
    do: "#{partial_license_plate}-__"

  defp fill_partial_inner(<<partial_license_plate::bytes-size(6)>>),
    do: "#{partial_license_plate}__"

  defp fill_partial_inner(<<partial_license_plate::bytes-size(7)>>),
    do: "#{partial_license_plate}_"

  defp fill_partial_inner(<<partial_license_plate::bytes-size(8)>>),
    do: "#{partial_license_plate}"

  defp fill_partial_inner(_), do: :invalid_license_plate

  @doc """
  Get a license plate that is in the middle of two license plates.

  NOTE: Only properly support license plates of the same type. If 
  different types provided will default for the begin of the newer 
  type.
  """
  @spec get_middle_between(binary(), binary()) :: binary()
  def get_middle_between(license_plate1, license_plate2) do
    {license_plate1, license_plate2} =
      if Validation.before_then!(license_plate1, license_plate2) do
        {license_plate1, license_plate2}
      else
        {license_plate2, license_plate1}
      end

    %{letters: letters1, numbers: numbers1, type: type1} = to_struct!(license_plate1)
    %{letters: letters2, numbers: numbers2, type: type2} = to_struct!(license_plate2)

    if type1 == type2 do
      new_numbers = get_middle_between_numbers(numbers1, numbers2, type1)

      new_letters = get_middle_between_letters(letters1, letters2)

      new_letters =
        if new_numbers > numbers1 do
          new_letters
        else
          next_letters(new_letters)
        end

      license_plate =
        %LicensePlate{type: type1, letters: new_letters, numbers: new_numbers}
        |> to_string()
        |> add_dash()

      if Validation.valid?(license_plate) do
        license_plate
      else
        # In some (rare) cases, we need to go to the next valid license plate
        roll_up_next_valid_license_plate(%LicensePlate{
          type: type1,
          letters: new_letters,
          numbers: new_numbers
        })
      end
    else
      case type2 do
        2 -> "00-01-AA"
        3 -> "00-AA-01"
        4 -> "AA-01-AA"
      end
    end
  end

  defp roll_up_next_valid_license_plate(%LicensePlate{type: type, letters: letters}) do
    start_number = if type != 4, do: 1, else: 0

    jump = invalid_letters_jump(type, letters, :next)

    new_letters =
      letters
      |> next_letters(jump)
      |> roll_up_kwy_letters

    %LicensePlate{type: type, letters: new_letters, numbers: start_number}
    |> to_string()
    |> add_dash()
  end

  defp roll_up_kwy_letters(letters) do
    letters
    |> String.split("", trim: true)
    |> Enum.reduce("", fn letter, acc ->
      if letter in ["K", "W", "Y"] do
        <<pos>> = letter
        "#{acc}#{<<pos + 1>>}"
      else
        "#{acc}#{letter}"
      end
    end)
  end

  def get_middle_between_numbers(numbers1, numbers2, type) do
    # Number1 represents the lower license plate
    # Number2 represents the upper license plate

    if numbers1 < numbers2 do
      numbers1 + floor(abs(numbers1 - numbers2) / 2)
    else
      max = if type < 4, do: @type123_max_number, else: @type4_max_number

      if max - numbers1 > numbers2 do
        numbers1 + floor((max - numbers1 + numbers2) / 2)
      else
        numbers2 - floor((max - numbers1 + numbers2) / 2)
      end
    end
    |> case do
      0 when type < 4 -> 1
      number -> number
    end
  end

  @doc """
  Get the middle letters between two letters.

  Example, the middle letter between AA and BZ is BA.

  Support for 2 and 4 letters.
  """
  def get_middle_between_letters(letters1, letters2)
      when byte_size(letters1) == 2 and byte_size(letters2) == 2 do
    <<letter11::utf8, letter12::utf8>> = letters1
    <<letter21::utf8, letter22::utf8>> = letters2

    if letter11 == letter21 do
      <<letter11, min(letter12, letter22) + floor(abs(letter12 - letter22) / 2)>>
    else
      letter1_value = (letter11 - @letter_lower_limit) * 25 + letter12
      letter2_value = (letter21 - @letter_lower_limit) * 25 + letter22

      middle_value = floor(abs(letter1_value - letter2_value) / 2)

      <<div(middle_value, 25) + @letter_lower_limit, rem(middle_value, 25) + @letter_lower_limit>>
    end
  end

  def get_middle_between_letters(letters1, letters2)
      when byte_size(letters1) == 4 and byte_size(letters2) == 4 do
    starting = convert_letters_to_number(letters1)
    difference = ceil((convert_letters_to_number(letters2) - starting) / 2)

    convert_number_to_letters(starting + difference, byte_size(letters1))
  end

  def convert_letters_to_number(letters) do
    letters
    |> String.split("", trim: true)
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {<<letter>>, index}, acc ->
      acc +
        (letter - @letter_lower_limit) *
          (:math.pow(26, index) |> Float.to_string() |> Integer.parse() |> elem(0))
    end)
  end

  @doc """
  Retrieve the letters belonging to a specific number.

  Number if reduced from higher index to lower index.
  """
  def convert_number_to_letters(number, digits \\ 4) do
    0..(digits - 1)
    |> Enum.reverse()
    |> Enum.reduce({[], number}, fn index, {chars, number} ->
      start = number_subtract_by_index(index)

      Logger.debug("number(#{number}) - start(#{start}) | index(#{index}) = #{number - start}")

      # 0 normaly menas B except when index is 0.
      if number - start > 0 || (number - start >= 0 && index > 0) do
        <<letter_ascii>> = get_letter_from_number_by_index(number, index)
        Logger.debug("Letter: #{<<letter_ascii>>}")

        {[<<letter_ascii>>] ++ chars,
         number - :math.pow(26, index) * (letter_ascii - @letter_lower_limit)}
      else
        # Defaults to A, when we start from with bigger index
        {["A"] ++ chars, number}
      end
    end)
    |> elem(0)
    |> Enum.reverse()
    |> Enum.join()
  end

  defp number_subtract_by_index(0), do: 0

  defp number_subtract_by_index(index) do
    :math.pow(26, abs(index))
    |> Float.to_string()
    |> Integer.parse()
    |> elem(0)
  end

  defp get_letter_from_number_by_index(number, index) do
    if number >= :math.pow(26, index) and number <= :math.pow(26, index + 1) do
      div = number / :math.pow(26, index)
      <<floor(div) + @letter_lower_limit>>
    else
      nil
    end
  end

  defguardp same_letters(l1, l2, l3, l4) when l1 == l2 and l2 == l3 and l3 == l4

  @vowels ["A", "E", "I", "O", "U"]
  defguardp contains_vowels_edge_cases(l1, l2, l3, l4)
            when (l1 in @vowels and l2 in @vowels and l4 in @vowels) or
                   (l2 in @vowels and l3 in @vowels and l4 in @vowels) or
                   (l2 in @vowels and l4 in @vowels)

  @type1_invalid_letters [
    "AM",
    "AP",
    "CC",
    "EM",
    "MB",
    "MC",
    "ME",
    "MF",
    "MG",
    "MH",
    "MI",
    "MJ",
    "ML",
    "MU",
    "MV",
    "MX",
    "MZ",
    "NU",
    "NV",
    "NZ",
    "OU",
    "OV",
    "OZ",
    "PR",
    "PU",
    "PV",
    "PZ",
    "QU",
    "QV",
    "QZ",
    "RU",
    "RV",
    "RZ",
    "SU",
    "SV",
    "SZ",
    "TB",
    "TC",
    "TD",
    "TE",
    "TF",
    "TG",
    "TH",
    "TJ",
    "TL",
    "TQ",
    "TZ",
    "UM",
    "UN",
    "UO",
    "UP",
    "UQ",
    "UR",
    "US",
    "UT",
    "UV",
    "VM",
    "VN",
    "VO",
    "VP",
    "VQ",
    "VR",
    "VS",
    "VT",
    "ZA",
    "ZC",
    "ZD",
    "ZG",
    "ZH",
    "ZI",
    "ZJ",
    "ZL",
    "ZM",
    "ZM",
    "ZQ",
    "ZT",
    "ZU",
    "ZV"
  ]

  @spec invalid_letters_jump(integer(), String.t(), :next | :prev) :: integer()
  defp invalid_letters_jump(1, letters, direction)
       when letters in @type1_invalid_letters or (letters >= "KA" and letters <= "KZ") do
    follow_letters =
      if direction == :next do
        next_letters(letters)
      else
        previous_letters(letters)
      end

    1 + invalid_letters_jump(1, follow_letters, direction)
  end

  defp invalid_letters_jump(2, letters, _) when letters in ["AS", "CU", "OO"], do: 1

  defp invalid_letters_jump(3, letters, _)
       when letters in ["AR", "AP", "CU", "HO", "ME", "MG", "MX", "OO"],
       do: 1

  defp invalid_letters_jump(3, "KA", :next), do: 6

  defp invalid_letters_jump(3, "KF", :prev), do: 6

  # Jump over AM and AN
  defp invalid_letters_jump(3, "AM", :next), do: 2

  defp invalid_letters_jump(3, "AN", :prev), do: 2

  # Can not pattern match on defguard, so we cannot extract this.
  defp invalid_letters_jump(
         4,
         <<l1::bytes-size(1), l2::bytes-size(1), l3::bytes-size(1), l4::bytes-size(1)>> =
           _letters,
         _
       )
       # I think this will also be banned, but need to wait to see.
       # (l1 in @vowels and l3 in @vowels) or
       when contains_vowels_edge_cases(l1, l2, l3, l4) and
              not same_letters(l1, l2, l3, l4) and not (l1 == l2 and l3 == l4) do
    1
  end

  defp invalid_letters_jump(4, <<l12::bytes-size(2)>> <> _, _) when l12 in ["AM", "AP"],
    do: 23 * 23

  @type4_forbidden_words ["ANAL"]
  defp invalid_letters_jump(4, letters, _) when letters in @type4_forbidden_words, do: 1

  defp invalid_letters_jump(_, _, _), do: 0

  @doc """
  Generate a license plate based on a partial license plate. 

  iex> LicensePlatePT.Manipulation.fill_earliest("AX-__-X_")
  "AX-00-XA"

  iex> LicensePlatePT.Manipulation.fill_earliest("AX-__-9_")
  "AX-00-90"
  """
  @spec fill_earliest(binary()) :: binary()
  def fill_earliest(license_plate_pattern) do
    case Information.get_type(license_plate_pattern) do
      [1] ->
        part1 =
          String.slice(license_plate_pattern, 0..1)
          |> String.replace("_", "A")

        part2 =
          license_plate_pattern
          |> String.slice(3..7)
          |> String.replace("_", "0")

        "#{part1}-#{part2}"
        |> String.replace("00-00", "00-01")

      [2] ->
        part1 =
          String.slice(license_plate_pattern, 6..7)
          |> String.replace("_", "A")

        part2 =
          license_plate_pattern
          |> String.slice(0..4)
          |> String.replace("_", "0")

        "#{part2}-#{part1}"
        |> String.replace("00-00", "00-01")

      [3] ->
        part1 =
          String.slice(license_plate_pattern, 0..1)
          |> String.replace("_", "0")

        part2 =
          String.slice(license_plate_pattern, 3..4)
          |> String.replace("_", "A")

        part3 =
          String.slice(license_plate_pattern, 6..7)
          |> String.replace("_", "0")

        if part1 == "00" and part3 == "00" do
          "00-#{part2}-01"
        else
          "#{part1}-#{part2}-#{part3}"
        end

      [4] ->
        part1 =
          String.slice(license_plate_pattern, 0..1)
          |> String.replace("_", "A")

        part2 =
          String.slice(license_plate_pattern, 3..4)
          |> String.replace("_", "0")

        part3 =
          String.slice(license_plate_pattern, 6..7)
          |> String.replace("_", "A")

        license_plate =
          "#{part1}-#{part2}-#{part3}"
          |> String.replace("AA-00-AA", "AA-01-AA")

        # Fix invalid cases with vowels
        if Validation.valid?(license_plate) do
          license_plate
        else
          "#{part1}-#{part2}-#{next_letters(part3)}"
        end

      _ ->
        # Can only generate for partial license plate 
        # that only can be of one license plate type.
        nil
    end
  end

  @doc """
  Generate a license plate based on a partial license plate. 

  iex> LicensePlatePT.Manipulation.fill_latest("AX-__-X_")
  "AX-99-XZ"

  iex> LicensePlatePT.Manipulation.fill_latest("AX-__-9_")
  "AX-99-99"
  """
  @spec fill_latest(binary()) :: binary()
  def fill_latest(license_plate_pattern) do
    case Information.get_type(license_plate_pattern) do
      [1] ->
        part1 =
          String.slice(license_plate_pattern, 0..1)
          |> String.replace("_", "Z")

        part2 =
          license_plate_pattern
          |> String.slice(3..7)
          |> String.replace("_", "9")

        "#{part1}-#{part2}"

      [2] ->
        part1 =
          String.slice(license_plate_pattern, 6..7)
          |> String.replace("_", "Z")

        part2 =
          license_plate_pattern
          |> String.slice(0..4)
          |> String.replace("_", "9")

        "#{part2}-#{part1}"

      [3] ->
        part1 =
          String.slice(license_plate_pattern, 0..1)
          |> String.replace("_", "9")

        part2 =
          String.slice(license_plate_pattern, 3..4)
          |> String.replace("_", "Z")

        part3 =
          String.slice(license_plate_pattern, 6..7)
          |> String.replace("_", "9")

        "#{part1}-#{part2}-#{part3}"

      [4] ->
        part1 =
          String.slice(license_plate_pattern, 0..1)
          |> String.replace("_", "Z")

        part2 =
          String.slice(license_plate_pattern, 3..4)
          |> String.replace("_", "9")

        part3 =
          String.slice(license_plate_pattern, 6..7)
          |> String.replace("_", "Z")

        "#{part1}-#{part2}-#{part3}"

      _ ->
        # Can only generate for partial license plate 
        # that only can be of one license plate type.
        nil
    end
  end

  @doc """
  Convert a license plate to partial.

  NOTE: To be development to support more than 3.
  """
  @spec to_partial(binary()) :: binary()
  def to_partial(license_plate, positions \\ 3)

  def to_partial(_, 6), do: "__-__-__"

  def to_partial(license_plate, 3) do
    if Validation.valid?(license_plate) do
      case Information.get_type(license_plate) do
        [1] ->
          "#{String.slice(license_plate, 0..3)}_-__"

        [2] ->
          "#{String.slice(license_plate, 0..0)}_-__-#{String.slice(license_plate, 6..7)}"

        [3] ->
          "#{String.slice(license_plate, 0..0)}_-#{String.slice(license_plate, 3..4)}-__"

        [4] ->
          "#{String.slice(license_plate, 0..1)}-__-#{String.slice(license_plate, 6..6)}_"

        _ ->
          nil
      end
    else
      nil
    end
  end

  def to_partial(_, position) when position in [1, 2, 4, 5] do
    nil
  end

  @doc """
  Split a license plate in 3 parts (left, middle and right, each with 2 alphanumeric characters)

  Supports with or without dash.
  """
  @spec split(<<_::6, _::_*8>> | <<_::8, _::_*8>>) :: list()
  def split(
        <<p1::binary-size(2)>> <> "-" <> <<p2::binary-size(2)>> <> "-" <> <<p3::binary-size(2)>>
      ) do
    [p1, p2, p3]
  end

  def split(<<p1::binary-size(2)>> <> <<p2::binary-size(2)>> <> <<p3::binary-size(2)>>) do
    [p1, p2, p3]
  end
end

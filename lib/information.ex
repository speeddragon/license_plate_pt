defmodule LicensePlatePT.Information do
  @moduledoc """
  Get information about a license plate.
  """

  alias LicensePlatePT.Validation

  import LicensePlatePT, only: [to_struct!: 1]

  require Logger

  @letter_lower_limit LicensePlatePT.get_letter_lower_limit()

  @type123_max_number LicensePlatePT.get_type123_max_number()

  @doc """
  Get license plate type.

  Type 1 -> Letters on the left side only
  Type 2 -> Letters on the right side only
  Type 3 -> Letters on the middle only
  Type 4 -> Letters on the left and right side.

  Return a list of possible license plates types.
  """
  @spec get_type(binary()) :: [integer()] | nil
  def get_type(license_plate) do
    cond do
      Validation.valid?(license_plate) ->
        %{type: type} = to_struct!(license_plate)
        [type]

      Validation.valid_partial?(license_plate) ->
        get_type_in_partial_license_plate(license_plate)

      true ->
        nil
    end
  end

  @spec get_type_in_partial_license_plate(binary()) :: [integer()]
  defp get_type_in_partial_license_plate(license_plate) when byte_size(license_plate) == 8 do
    license_plate
    |> String.replace("-", "")
    |> get_type_in_partial_license_plate()
  end

  # credo:disable-for-next-line
  defp get_type_in_partial_license_plate(license_plate) when byte_size(license_plate) == 6 do
    pair1 = String.slice(license_plate, 0..1)
    pair2 = String.slice(license_plate, 2..3)
    pair3 = String.slice(license_plate, 4..5)

    case {get_pair_type(pair1), get_pair_type(pair2), get_pair_type(pair3)} do
      {:letter, _, p2} when p2 in [:number] -> [1]
      {p1, _, :letter} when p1 in [:number] -> [2]
      {_, :letter, _} -> [3]
      {:number, _, :number} -> [3]
      {:letter, _, :letter} -> [4]
      {:letter, _, _} -> [1, 4]
      {_, _, :letter} -> [2, 4]
      {_, _, :number} -> [1, 3]
      {:number, _, _} -> [2, 3]
      {:any, :any, :any} -> [1, 2, 3, 4]
      _value -> nil
    end
  end

  @spec get_pair_type(String.t()) :: :any | :number | :letter | nil
  defp get_pair_type(pair) do
    cond do
      pair == "__" -> :any
      String.match?(pair, ~r/\d/) -> :number
      String.match?(pair, ~r/[A-Z]/) -> :letter
      true -> nil
    end
  end

  @spec has_kwy(binary) :: boolean()
  defp has_kwy(letters) do
    letters = String.upcase(letters)

    String.contains?(letters, "K") or
      String.contains?(letters, "W") or
      String.contains?(letters, "Y")
  end

  @doc """
  Calculate the distance between two license plates.

  If license plates contain invalid letters, it will return `nil`.
  """
  @spec distance_between(binary(), binary()) :: integer() | nil
  def distance_between(license_plate1, license_plate2) do
    %{type: type1, letters: letters1, numbers: numbers1} =
      LicensePlatePT.to_struct!(license_plate1)

    %{type: type2, letters: letters2, numbers: numbers2} =
      LicensePlatePT.to_struct!(license_plate2)

    number_between_letters = if type2 == 4, do: 100, else: 10_000

    letter2_distance = letters_distance_to_beginning(letters2)
    letter1_distance = letters_distance_to_beginning(letters1)

    cond do
      # Only calculate if both license plate has KWY or neither has it.
      has_kwy(letters1) != has_kwy(letters2) ->
        nil

      is_nil(letter2_distance) or is_nil(letter1_distance) ->
        nil

      type1 == type2 ->
        result =
          (letter2_distance - letter1_distance) * number_between_letters +
            (numbers2 - numbers1)

        abs(result)

      true ->
        # We assume that the difference will be always 1.
        {letters1, letters2} =
          if type1 < type2 do
            # 10000, because type 1 will always be less than 4
            {letters1, letters2}
          else
            {letters2, letters1}
          end

        result =
          (letters_distance_to_beginning("ZZ") - letters_distance_to_beginning(letters1)) * 10_000 +
            letters_distance_to_beginning(letters2) * number_between_letters + numbers2 -
            (@type123_max_number - numbers1) + 1

        abs(result)
    end
  end

  @kwy ["K", "W", "Y"]

  @doc """
  Get the letters distance to the beginning.

  Doesn't support K, W and Y for Type 4.

  ## Examples

  iex> LicensePlatePT.Information.letters_distance_to_beginning("AAAA")
  0

  iex> LicensePlatePT.Information.letters_distance_to_beginning("AABA")
  23
  """
  @spec letters_distance_to_beginning(binary()) :: integer() | nil
  def letters_distance_to_beginning(
        <<l1::bytes-size(1), l2::bytes-size(1), l3::bytes-size(1), l4::bytes-size(1)>>
      )
      when l1 in @kwy or l2 in @kwy or l3 in @kwy or l4 in @kwy,
      do: nil

  def letters_distance_to_beginning(letters) do
    letters_count = 23

    letters
    |> String.upcase()
    |> String.to_charlist()
    |> Enum.reverse()
    |> Enum.reduce({0, 1}, fn letter_decimal, {m, acc} ->
      {
        m + 1,
        acc +
          (adjust_letter_count(letter_decimal) - @letter_lower_limit) *
            floor(:math.pow(letters_count, m))
      }
    end)
    |> elem(1)
    # If we are at the beginning, to A is 0 left.
    |> Kernel.-(1)
  end

  # Depending where we are (between A to Z), consider 23 chars alphabet.
  @spec adjust_letter_count(integer()) :: integer()
  def adjust_letter_count(letter_decimal) do
    cond do
      letter_decimal > ?Y -> letter_decimal - 3
      letter_decimal > ?W -> letter_decimal - 2
      letter_decimal > ?K -> letter_decimal - 1
      true -> letter_decimal
    end
  end

  @doc """
  Get the number of plates possible with a pattern

  In this aren't considered the special plates, like AK, KA, AM, AO, HO and others.
  All numbers are based on: one number can have 10 plates, one letter can have 23 (26 except K, W and Y)
  """
  @spec get_possibilities(String.t()) :: integer()
  def get_possibilities("__-__-__") do
    type_1_2_3 = 23 * 23 * 10_000 * 3
    type_4 = 23 * 23 * 23 * 23 * 100

    type_1_2_3 + type_4
  end

  def get_possibilities(license_plate_pattern) do
    license_plate_types = get_type(license_plate_pattern)

    Enum.reduce(license_plate_types, 0, fn
      plate_type, count when plate_type in [1, 2, 3] ->
        count + get_possibilities_type_123(license_plate_pattern)

      4, count ->
        count + get_possibilities_type_4(license_plate_pattern)

      plate_type, count ->
        Logger.error("Invalid plate type: #{plate_type}")
        count
    end)
  end

  # Possibilities for type 1, 2 and 3.
  defp get_possibilities_type_123(license_plate_pattern) do
    case get_letters_position(license_plate_pattern) do
      :none ->
        letters_count = 23 * 23

        numbers_count =
          license_plate_pattern
          |> String.split("")
          |> Enum.reject(&(&1 in ["-", ""]))
          |> Enum.reduce(1, fn
            "_", acc -> acc * 10
            _, acc -> acc
          end)
          # Remove the 2 empty spaces from letters
          |> Kernel./(100)
          # Duplicate possibilities
          |> case do
            value when value > 10 -> value * 2
            value -> value
          end

        letters_count * numbers_count

      letters_position ->
        Logger.debug("get_possibilities - Letters Found")

        letter_count = get_letter_count(letters_position, license_plate_pattern)

        rest_count =
          license_plate_pattern
          |> String.split("")
          |> Enum.reject(&(&1 in ["-", ""]))
          |> Enum.reduce(1, fn
            "_", acc -> acc * 10
            _, acc -> acc
          end)

        # Remove one count because of only found one letter
        rest_count =
          if letter_count == 1 do
            rest_count
          else
            rest_count / 10
          end

        letter_count * rest_count
    end
  end

  defp get_letter_count(letters_position, license_plate_pattern) do
    if letters_position == :two_letters do
      1
    else
      # Normal
      letter_count = 23

      # Special Case: K_
      if String.contains?(license_plate_pattern, "K_"),
        do: 6,
        else: letter_count
    end
  end

  @spec get_possibilities_type_4(binary()) :: non_neg_integer()
  defp get_possibilities_type_4(license_plate_pattern) do
    String.split(license_plate_pattern, "")
    |> Enum.reject(&(&1 in ["", "-"]))
    |> Enum.with_index()
    |> Enum.reduce(1, fn
      {"_", index}, count when index in [0, 1, 4, 5] -> count * 23
      {"_", index}, count when index in [2, 3] -> count * 10
      {_, _}, count -> count
    end)
  end

  # Indicate the letter status/position of a plate (for type 1/2/3)
  @spec get_letters_position(String.t()) :: :two_letters | :none | integer()
  defp get_letters_position(license_plate_pattern) do
    plate_sections = String.split(license_plate_pattern, "-")

    plate_sections
    |> Enum.with_index()
    |> Enum.reduce_while(:none, fn
      {<<first, second>>, _index}, _ when first in ?A..?Z and second in ?A..?Z ->
        {:halt, :two_letters}

      {<<first, second>>, index}, _ when first in ?A..?Z or second in ?A..?Z ->
        # Position of 3 possible places (0,3,6)
        #
        # AA-00-00 (0)
        # 00-AA-00 (3)
        # 00-00-AA (6)

        {:halt, index * 3}

      _, acc ->
        {:cont, acc}
    end)
  end
end

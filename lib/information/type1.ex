defmodule LicensePlatePT.Information.Type1 do
  @moduledoc """
  Type 1 year information.
  """

  @years %{
    "AF" => ~w(73 82),
    "AE" => ~w(69 70 82),
    "AG" => ~w(71 82),
    "AH" => ~w(68 69 82),
    "AI" => ~w(63 83),
    "AJ" => ~w(83 84),
    "AL" => ~w(68 69 82),
    "AN" => ~w(74 ),
    "AO" => ~w(73 81),
    "AQ" => ~w(86),
    "AR" => ~w(74),
    "AS" => ~w(80 ),
    "AT" => ~w(75 76 81),
    "AU" => ~w(80 81),
    "AV" => ~w(74 81),
    "AX" => ~w(90),
    "AZ" => ~w(77 80 81),
    "BA" => ~w(61 62 82),
    "BB" => ~w(71 72 82),
    "BC" => ~w(70 71 82),
    "BD" => ~w(56 57 58 71 72 82),
    "BE" => ~w(73 82),
    "BF" => ~w(69 73 80 82 87),
    "BG" => ~w(67 68 82),
    "BH" => ~w(70 71 72 82),
    "BI" => ~w(70 71 82),
    "BJ" => ~w(84),
    "BL" => ~w(61 62 82),
    "BM" => ~w(73 81),
    "BO" => ~w(74 75 81),
    "BP" => ~w(75 76 81),
    "BQ" => ~w(86),
    "BR" => ~w(74 81),
    "BS" => ~w(80 81 82),
    "BT" => ~w(75 80 81),
    "BU" => ~w(74 75 80),
    "BV" => ~w(80 81),
    "BX" => ~w(90),
    "BZ" => ~w(76 78 79 81),
    "CA" => ~w(73 74 82),
    "CB" => ~w(64 65 82),
    "CE" => ~w(61 62 82),
    "CF" => ~w(72 73 82),
    "CG" => ~w(72 81 82),
    "CH" => ~w(69 70 71 72 82),
    "CI" => ~w(58 59 82),
    "CJ" => ~w(84),
    "CL" => ~w(63 64 82),
    "CM" => ~w(78 81),
    "CN" => ~w(77 81),
    "CO" => ~w(74 81),
    "CP" => ~w(75 81),
    "CQ" => ~w(86),
    "CR" => ~w(74 81),
    "CS" => ~w(73 74 81),
    "CT" => ~w(75 76 80 81),
    "CU" => ~w(82),
    "CV" => ~w(79 81),
    "CX" => ~w(90),
    "CZ" => ~w(80 81),
    "DA" => ~w(66 67 68 82),
    "DB" => ~w(66 67 82),
    "DC" => ~w(65 66 82),
    "DE" => ~w(66 72 82),
    "DF" => ~w(67 68 69 82),
    "DG" => ~w(71 82),
    "DH" => ~w(69 70 82),
    "DI" => ~w(56 70 82),
    "DJ" => ~w(84),
    "DL" => ~w(72 73 82 83),
    "DM" => ~w(78 81),
    "DN" => ~w(73 75 81),
    "DO" => ~w(74 75 81),
    "DP" => ~w(74 75 81),
    "DQ" => ~w(86 87),
    "DR" => ~w(73 75 78 79 81),
    "DS" => ~w(73 75 76 81),
    "DT" => ~w(76 77 81),
    "DU" => ~w(81),
    "DV" => ~w(77 78 81),
    "DX" => ~w(90),
    "DZ" => ~w(78 79 80 81),
    "EA" => ~w(60 61 62 71),
    "EB" => ~w(68 71 82),
    "EC" => ~w(67 68 82),
    "ED" => ~w(68 69 82),
    "EE" => ~w(72 82),
    "EF" => ~w(68 82),
    "EG" => ~w(71 72 82),
    "EH" => ~w(72 73 81 82),
    "EI" => ~w(62 63 68 73 82),
    "EJ" => ~w(84),
    "EL" => ~w(66 72 73 82),
    "EN" => ~w(75 76 81 82),
    "EO" => ~w(79 81),
    "EQ" => ~w(87),
    "ER" => ~w(74 81),
    "ES" => ~w(79 80 81),
    "ET" => ~w(77 78 81),
    "EU" => ~w(80 81),
    "EX" => ~w(90),
    "EZ" => ~w(76 81),
    "FA" => ~w(71 72),
    "FB" => ~w(70 71 73),
    "FC" => ~w(66 67 82),
    "FD" => ~w(83),
    "FE" => ~w(64 65 82),
    "FF" => ~w(72 82),
    "FG" => ~w(66 71 82),
    "FH" => ~w(72 82),
    "FI" => ~w(71 82),
    "FJ" => ~w(84),
    "FL" => ~w(69 70 82),
    "FN" => ~w(75 77 78 81),
    "FO" => ~w(75 81),
    "FP" => ~w(73 81),
    "FQ" => ~w(87),
    "FR" => ~w(78 81),
    "FS" => ~w(77 81),
    "FT" => ~w(80 82),
    "FU" => ~w(80 81),
    "FV" => ~w(76 81),
    "FX" => ~w(80 90),
    "FZ" => ~w(78 81),
    "GA" => ~w(71 72 82),
    "GB" => ~w(66 82),
    "GC" => ~w(72 73 82),
    "GD" => ~w(57 58 82),
    "GE" => ~w(64 65 66 73 82),
    "GF" => ~w(60 64 82),
    "GG" => ~w(72 73 81),
    "GH" => ~w(69 70 82),
    "GI" => ~w(66 82),
    "GJ" => ~w(84),
    "GL" => ~w(66 67 82),
    "GM" => ~w(75 81 87),
    "GN" => ~w(74 81 87),
    "GO" => ~w(57 75 76 81),
    "GP" => ~w(77 81),
    "GQ" => ~w(87),
    "GR" => ~w(79 80 81 89),
    "GS" => ~w(76 81),
    "GT" => ~w(79 81 89),
    "GU" => ~w(77 81),
    "GV" => ~w(81),
    "GX" => ~w(90),
    "GZ" => ~w(76 77 81),
    "HA" => ~w(72 73 81 82),
    "HB" => ~w(65 66 82),
    "HC" => ~w(66 67 82),
    "HD" => ~w(63 64 82),
    "HE" => ~w(59 60 82),
    "HF" => ~w(65 66 82),
    "HG" => ~w(72 82),
    "HH" => ~w(60 61 82),
    "HI" => ~w(59 60 82),
    "HJ" => ~w(84),
    "HL" => ~w(67 68 82),
    "HM" => ~w(64 74 75 81),
    "HN" => ~w(73 74 81),
    "HP" => ~w(79 80 81),
    "HQ" => ~w(87),
    "HR" => ~w(78 81),
    "HS" => ~w(80 81),
    "HT" => ~w(76 81 82),
    "HU" => ~w(77 81),
    "HV" => ~w(76 77 81),
    "HX" => ~w(90),
    "HZ" => ~w(77 81),
    "IA" => ~w(62 82),
    "IB" => ~w(64 69 82),
    "IC" => ~w(70 82),
    "ID" => ~w(67 68 82),
    "IE" => ~w(71 82),
    "IF" => ~w(58 59 82),
    "IG" => ~w(62 63 82),
    "IH" => ~w(71 72 82),
    "II" => ~w(63 64 82),
    "IJ" => ~w(84 88),
    "IL" => ~w(62 69 82),
    "IM" => ~w(73 74 76 81),
    "IN" => ~w(78 82),
    "IO" => ~w(78 81),
    "IP" => ~w(76 77 81),
    "IQ" => ~w(87),
    "IR" => ~w(80 81),
    "IS" => ~w(79 81),
    "IT" => ~w(76 81),
    "IU" => ~w(76 81),
    "IV" => ~w(81),
    "IX" => ~w(90),
    "IZ" => ~w(77 81),
    "JA" => ~w(85),
    "JB" => ~w(85),
    "JC" => ~w(85),
    "JD" => ~w(85),
    "JE" => ~w(85),
    "JF" => ~w(85),
    "JG" => ~w(85),
    "JH" => ~w(85),
    "JI" => ~w(85),
    "JJ" => ~w(84 88),
    "JL" => ~w(85),
    "JM" => ~w(85 86),
    "JN" => ~w(86),
    "JO" => ~w(86),
    "JP" => ~w(86),
    "JQ" => ~w(87),
    "JR" => ~w(86),
    "JS" => ~w(86),
    "JT" => ~w(86),
    "JU" => ~w(86),
    "JV" => ~w(86),
    "JX" => ~w(90 91),
    "JZ" => ~w(86),
    "LA" => ~w(69 82),
    "LB" => ~w(67 68 82),
    "LC" => ~w(58 82),
    "LD" => ~w(69 82),
    "LE" => ~w(65 66 82),
    "LF" => ~w(70 71 82),
    "LG" => ~w(66 67 82),
    "LH" => ~w(70 82 85),
    "LJ" => ~w(85),
    "LM" => ~w(88),
    "LN" => ~w(89),
    "LQ" => ~w(88),
    "MN" => ~w(75),
    "MO" => ~w(90),
    "MP" => ~w(56 86),
    "MQ" => ~w(90),
    "MR" => ~w(63 64 65 66),
    "MS" => ~w(71 72 73),
    "MT" => ~w(57 58 59 ),
    "NA" => ~w(82 83),
    "NB" => ~w(82 83),
    "NC" => ~w(83),
    "ND" => ~w(83),
    "NE" => ~w(83),
    "NF" => ~w(83),
    "NG" => ~w(83),
    "NH" => ~w(83),
    "NI" => ~w(83),
    "NJ" => ~w(83 88),
    "NL" => ~w(83),
    "NM" => ~w(73 74 76),
    "NN" => ~w(73 74 75),
    "NO" => ~w(75),
    "NP" => ~w(78 79),
    "NQ" => ~w(90 91),
    "NR" => ~w(72 73),
    "NS" => ~w(67 85),
    "NT" => ~w(83),
    "NU" => ~w(83),
    "NX" => ~w(91),
    "OA" => ~w(87),
    "OB" => ~w(87),
    "OC" => ~w(87),
    "OD" => ~w(87),
    "OE" => ~w(77 87 88),
    "OF" => ~w(87),
    "OG" => ~w(87),
    "OH" => ~w(87 88),
    "OI" => ~w(87 88),
    "OJ" => ~w(87 88),
    "OL" => ~w(88),
    "OM" => ~w(83),
    "ON" => ~w(71 73 74),
    "OO" => ~w(66 67 78 79 82),
    "OP" => ~w(59 60 61 65 66 73 82),
    "OQ" => ~w(91),
    "OR" => ~w(57 58 76 77 82),
    "OS" => ~w(71 72 73 82),
    "OT" => ~w(82),
    "OX" => ~w(91),
    "PA" => ~w(88),
    "PB" => ~w(88 89),
    "PC" => ~w(88),
    "PD" => ~w(88),
    "PE" => ~w(88),
    "PF" => ~w(88),
    "PG" => ~w(88),
    "PH" => ~w(88),
    "PI" => ~w(88),
    "PJ" => ~w(88 89),
    "PL" => ~w(88),
    "PM" => ~w(73 74 75),
    "PN" => ~w(68 69 70),
    "PO" => ~w(75 76 77 78),
    "PP" => ~w(69 70 71 72),
    "PQ" => ~w(91),
    "PS" => ~w(77 78 79),
    "PT" => ~w(84),
    "PX" => ~w(91),
    "QA" => ~w(88),
    "QB" => ~w(88),
    "QC" => ~w(88 89),
    "QD" => ~w(88 89),
    "QE" => ~w(88),
    "QF" => ~w(88 90),
    "QG" => ~w(88 89),
    "QH" => ~w(88 89),
    "QI" => ~w(88 89),
    "QJ" => ~w(88 89 92),
    "QL" => ~w(88 89),
    "QM" => ~w(87),
    "QN" => ~w(87),
    "QO" => ~w(88),
    "QP" => ~w(89),
    "QQ" => ~w(89),
    "QR" => ~w(89),
    "QT" => ~w(90),
    "QX" => ~w(91),
    "RA" => ~w(88 89),
    "RB" => ~w(88 89),
    "RC" => ~w(89),
    "RD" => ~w(89),
    "RE" => ~w(79 89),
    "RF" => ~w(89),
    "RG" => ~w(89),
    "RH" => ~w(89),
    "RI" => ~w(89),
    "RJ" => ~w(89),
    "RL" => ~w(89),
    "RM" => ~w(87),
    "RN" => ~w(84 85),
    "RO" => ~w(85),
    "RP" => ~w(86),
    "RQ" => ~w(91),
    "RR" => ~w(68 69),
    "RS" => ~w(84),
    "RT" => ~w(69 70 71),
    "RX" => ~w(91),
    "SA" => ~w(89),
    "SB" => ~w(78 89),
    "SC" => ~w(89),
    "SD" => ~w(89),
    "SE" => ~w(89),
    "SF" => ~w(89),
    "SG" => ~w(89),
    "SH" => ~w(89),
    "SI" => ~w(89),
    "SJ" => ~w(89),
    "SL" => ~w(89),
    "SM" => ~w(75 76),
    "SN" => ~w(67 68 69),
    "SO" => ~w(70 71 73),
    "SP" => ~w(86),
    "SQ" => ~w(70 71 72 91 92),
    "SR" => ~w(76 77 78 79),
    "SS" => ~w(80),
    "ST" => ~w(75),
    "SX" => ~w(91),
    "TM" => ~w(79 83),
    "TN" => ~w(83),
    "TO" => ~w(61 62 63),
    "TP" => ~w(86),
    "TR" => ~w(81),
    "TS" => ~w(83),
    "TU" => ~w(74),
    "TX" => ~w(91),
    "UA" => ~w(89),
    "UB" => ~w(89),
    "UC" => ~w(89),
    "UD" => ~w(89),
    "UE" => ~w(89 90),
    "UF" => ~w(90),
    "UG" => ~w(90),
    "UH" => ~w(90),
    "UI" => ~w(90),
    "UJ" => ~w(90),
    "UL" => ~w(90),
    "UX" => ~w(91),
    "UZ" => ~w(78 79),
    "VA" => ~w(90),
    "VB" => ~w(90),
    "VC" => ~w(90),
    "VD" => ~w(90),
    "VF" => ~w(90),
    "VG" => ~w(90),
    "VH" => ~w(90),
    "VI" => ~w(90),
    "VJ" => ~w(90),
    "VL" => ~w(90),
    "VX" => ~w(91),
    "VZ" => ~w(73),
    "XA" => ~w(91),
    "XB" => ~w(91),
    "XC" => ~w(91),
    "XD" => ~w(91),
    "XE" => ~w(91),
    "XF" => ~w(91),
    "XG" => ~w(91),
    "XH" => ~w(91),
    "XI" => ~w(91),
    "XJ" => ~w(91),
    "XL" => ~w(91),
    "XM" => ~w(91),
    "XN" => ~w(91),
    "XO" => ~w(91),
    "XP" => ~w(91),
    "XQ" => ~w(91),
    "XR" => ~w(91 92),
    "XS" => ~w(92),
    "XT" => ~w(92),
    "XU" => ~w(92),
    "XV" => ~w(92),
    "XX" => ~w(91),
    "XZ" => ~w(92),
    "ZB" => ~w(92),
    "ZE" => ~w(74 75 77),
    "ZF" => ~w(75 76),
    "ZO" => ~w(92),
    "ZU" => ~w(77),
    "ZZ" => ~w(74)
  }

  # In some cases, the first 1000 weren't used, only later started 
  # to be used, so assigned to later years.
  @special_number_section 1000
  @spec get_year(String.t()) :: 1900..1992 | nil
  def get_year(license_plate) when is_binary(license_plate) do
    case LicensePlatePT.to_struct(license_plate) do
      {:ok, %LicensePlatePT.LicensePlate{type: 1, letters: letters, numbers: numbers}} ->
        case get_years_by_letters(letters) do
          [year] ->
            year

          years ->
            handle_multiple_years(years, numbers)
        end

      _ ->
        nil
    end
  end

  @spec handle_multiple_years(list(non_neg_integer()), non_neg_integer()) :: non_neg_integer()
  defp handle_multiple_years(years, numbers) when is_list(years) and is_integer(numbers) do
    if all_sequential?(years) do
      years_length = length(years)
      pinpoint = floor(numbers / LicensePlatePT.get_type123_max_number() * years_length)
      Enum.at(years, pinpoint)
    else
      if numbers < @special_number_section do
        List.last(years)
      else
        sequential_years = get_only_sequencial_numbers(years)

        years_length = length(sequential_years)

        pinpoint =
          floor(
            (numbers - @special_number_section) /
              (LicensePlatePT.get_type123_max_number() - @special_number_section) *
              years_length
          )

        Enum.at(sequential_years, pinpoint)
      end
    end
  end

  @spec get_years_by_letters(<<_::16, _::_*8>>) :: list(integer()) | nil
  def get_years_by_letters(<<_::binary-size(2)>> = letters) do
    Map.get(@years, letters)
    |> Enum.map(fn year -> String.to_integer(year) end)
  end

  def get_region_by_letters(letters) when letters in ["AA", "AB", "AC", "AD", "EM", "EV"] do
    :south
  end

  def get_region_by_letters(letters) when letters in ["MM", "MN", "SS"], do: :north
  def get_region_by_letters("UU"), do: :center
  def get_region_by_letters("AN"), do: :azores_terceira
  def get_region_by_letters("AR"), do: :azores
  def get_region_by_letters("HO"), do: :azores_faial

  @motorcycle %{
    "E" => ~w(M),
    "L" => ~w(I L M N O Q R S T V Z),
    "T" => ~w(T Z),
    "Z" => ~w(Z)
  }
  def motorcycle?(<<p::binary-size(1), s::binary-size(1)>>) do
    Map.get(@motorcycle, p, []) |> Enum.member?(s)
  end

  @spec all_sequential?(list(integer())) :: boolean()
  defp all_sequential?([start_number | rem]) do
    Enum.reduce_while(rem, start_number, fn value, previous_number ->
      if value == previous_number + 1 do
        {:cont, value}
      else
        {:halt, false}
      end
    end)
    |> case do
      false -> false
      _ -> true
    end
  end

  defp all_sequential?(_), do: false

  @spec get_only_sequencial_numbers(list(integer())) :: list(integer())
  defp get_only_sequencial_numbers([start_number | rem_years]) do
    Enum.reduce_while(rem_years, [start_number], fn year, [previous_year | _] = acc ->
      if year == previous_year + 1 do
        {:cont, [year] ++ acc}
      else
        {:halt, acc}
      end
    end)
    |> Enum.reverse()
  end
end

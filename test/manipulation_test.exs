defmodule LicensePlatePT.ManipulationTest do
  @moduledoc false

  @subject LicensePlatePT.Manipulation
  use ExUnit.Case
  doctest @subject

  describe "add_dash" do
    test "undashed license plate" do
      assert "AD-54-33" == @subject.add_dash("AD5433")
    end

    test "undashed lower case license plate" do
      assert "AD-54-33" == @subject.add_dash("ad5433")
    end

    test "dashed license plate" do
      assert "AD-54-33" == @subject.add_dash("AD-54-33")
    end

    test "nil" do
      assert is_nil(@subject.add_dash(nil))
    end
  end

  describe "Fill partial" do
    test "Length 0", do: assert({:ok, "__-__-__"} == @subject.fill_partial(""))
    test "Length 1", do: assert({:ok, "A_-__-__"} == @subject.fill_partial("A"))
    test "Length 2", do: assert({:ok, "09-__-__"} == @subject.fill_partial("09"))
    test "Length 3", do: assert({:ok, "IU-__-__"} == @subject.fill_partial("IU-"))
    test "Length 4", do: assert({:ok, "AO-2_-__"} == @subject.fill_partial("AO-2"))
    test "Length 5", do: assert({:ok, "00-00-__"} == @subject.fill_partial("00-00"))
    test "Length 6", do: assert({:ok, "AB-12-__"} == @subject.fill_partial("AB-12-"))
    test "Length 7", do: assert({:ok, "DF-30-3_"} == @subject.fill_partial("DF-30-3"))
    test "Length 8", do: assert({:ok, "88-89-DF"} == @subject.fill_partial("88-89-DF"))

    test "Length 9",
      do: assert({:error, :invalid_license_plate} == @subject.fill_partial("34-33-RSA"))
  end

  describe "Next License Plate" do
    test "Normal" do
      assert "AA-00-12" == @subject.next("AA-00-11")
      assert "AA0012" == @subject.next("AA0011")
    end

    test "Edges cases" do
      assert "LA-00-01" == @subject.next("JZ-99-99")
      assert "00-01-AA" == @subject.next("ZZ-99-99")
      assert "00-01-KA" == @subject.next("99-99-JZ")
      assert "00-01-LA" == @subject.next("99-99-KF")
      assert "00-AA-01" == @subject.next("99-99-ZZ")
      assert "00-LA-01" == @subject.next("99-JZ-99")
      assert "AA-01-AA" == @subject.next("99-ZZ-99")
      assert is_nil(@subject.next("ZZ-99-ZZ"))
      assert is_nil(@subject.next(nil))

      assert "00-01-AZ" == @subject.next("99-99-AX")
      assert "AA-00-AB" == @subject.next("AA-99-AA")
    end

    test "Avoid invalid letters - Type 1" do
      # Type 1
      assert "UU-00-01" == @subject.next("UL-99-99")
    end

    test "Avoid invalid letters - Type 2" do
      # Type 2
      assert "00-01-OP" == @subject.next("99-99-ON")
      assert "00-01-CV" == @subject.next("99-99-CT")
    end

    test "Avoid invalid letters - Type 3" do
      # Type 3
      assert "00-AO-01" == @subject.next("99-AL-99")
    end

    test "Avoid invalid letters - Type 4 - 3 vowels with 2 vowels on the start (AA, AE, AI, AO, AU) and 1 at the end" do
      # AI-__-CI
      assert @subject.next("AO-99-CH") == "AO-00-CJ"
      # AO-__-CA
      assert @subject.next("AO-99-CH") == "AO-00-CJ"
      # AA-__-HU
      assert @subject.next("AO-99-HT") == "AO-00-HV"
    end

    test "Avoid invalid letters - Type 4 - 3 vowels with 2 vowels on the end (AA, AE, AI, AO, AU) and 1 at the start" do
      # BA-__-EE
      assert @subject.next("BA-99-ED") == "BA-00-EF"
    end

    test "Avoid invalid letters - Type 4 - 4 Vowels" do
      # AI-__-LA
      assert @subject.next("AI-99-JZ") == "AI-00-LB"

      # AE-__-AE
      assert @subject.next("AE-99-AD") == "AE-00-AF"

      # AU-__-AO
      assert @subject.next("AU-99-AN") == "AU-00-AP"
    end

    test "Avoid invalid letters - Type 4 - 4 Vowles (Only valid case)" do
      assert @subject.next("AA-08-AA") == "AA-09-AA"
      assert @subject.next("AA-01-EE") == "AA-02-EE"
      assert @subject.next("AA-99-IH") == "AA-00-II"
    end

    test "Avoid invalid letters - Type 4" do
      # ANAL
      assert @subject.next("AN-99-AJ") == "AN-00-AM"

      # The pattern is any vowel in 2nd and 4th letter position.
      assert @subject.next("BA-99-BZ") == "BA-00-CB"
      assert @subject.next("BI-99-GN") == "BI-00-GP"
      assert @subject.next("BI-99-JD") == "BI-00-JF"
      assert @subject.next("BA-99-DD") == "BA-00-DF"
    end

    test "More than 1 time" do
      assert "AA0071" == @subject.next("AA0011", 60)
    end

    test "Support map/struct" do
      assert "AA0012" == @subject.next(%{license_plate: "AA0011"})
    end

    test "Support negative values" do
      assert "AA-00-12" == @subject.next("AA-00-14", -2)
    end
  end

  describe "Previous License Plate" do
    test "Normal" do
      assert "AA-00-11" == @subject.previous("AA-00-12")
      assert "AA0011" == @subject.previous("AA0012")
    end

    test "Leap over double zero in type 1, 2 and 3" do
      # Type 1 
      assert "RR-99-99" == @subject.previous("RS-00-01")

      # Type 2
      assert "99-99-AX" == @subject.previous("00-01-AZ")

      # Type 3 
      assert "99-AX-99" == @subject.previous("00-AZ-01")

      # Type 4 doesn't leep
      assert "AA-00-AB" == @subject.previous("AA-01-AB")
      assert "AA-99-AA" == @subject.previous("AA-00-AB")
    end

    test "Leap over plate types" do
      # Type 2 to 1
      assert "ZZ-99-99" == @subject.previous("00-01-AA")
      # Type 3 to 2
      assert "99-99-ZZ" == @subject.previous("00-AA-01")
      # Type 4 to 3
      assert "99-ZZ-99" == @subject.previous("AA-01-AA")
    end

    test "1997 Imported Zone" do
      assert "99-99-JZ" == @subject.previous("00-01-KA")
      assert "99-99-KF" == @subject.previous("00-01-LA")
    end

    test "Jump over invalid letters - Type 1" do
      assert "JZ-99-99" == @subject.previous("LA-00-01")
      assert "RX-99-99" == @subject.previous("SA-00-01")
    end

    test "Jump over invalid letters - Type 2" do
      assert "99-99-ON" == @subject.previous("00-01-OP")
      assert "99-99-CT" == @subject.previous("00-01-CV")
    end

    test "Jump over invalid letters - Type 3" do
      assert "99-JZ-99" == @subject.previous("00-LA-01")
      assert @subject.previous("00-AO-01") == "99-AL-99"
    end

    test "Jump over invalid letters - Type 4 - 3 vowels with 2 vowels on the start (AA, AE, AI, AO, AU) and 1 at the end" do
      # AI-__-CI
      assert @subject.previous("AO-00-CJ") == "AO-99-CH"
      # AO-__-CA
      assert @subject.previous("AO-00-CB") == "AO-99-BZ"
      # AA-__-HU
      assert @subject.previous("AO-00-HV") == "AO-99-HT"
    end

    test "Avoid invalid letters - Type 4 - 3 vowels with 2 vowels on the end (AA, AE, AI, AO, AU) and 1 at the start" do
      # BA-__-EE
      assert @subject.previous("BA-00-EF") == "BA-99-ED"
    end

    test "Avoid invalid letters - Type 4 - 4 Vowels" do
      # AI-__-LA
      assert @subject.previous("AI-00-LB") == "AI-99-JZ"

      # AE-__-AE
      assert @subject.previous("AE-00-AF") == "AE-99-AD"

      # AU-__-AO
      assert @subject.previous("AU-00-AP") == "AU-99-AN"
    end

    test "Jump over invalid letters Type 4" do
      assert @subject.previous("AN-00-AA") == "AL-99-ZZ"
    end

    test "Avoid invalid letters - Type 4 - 4 Vowles (Only valid case)" do
      assert @subject.previous("AA-00-AB") == "AA-99-AA"
    end

    test "Avoid invalid letters (ANAL) - Type 4" do
      assert @subject.previous("AN-00-AM") == "AN-99-AJ"
    end

    test "Invalid values" do
      assert is_nil(@subject.previous(nil))
    end

    test "Begining/Ending" do
      assert is_nil(@subject.previous("AA-00-01"))
    end

    test "More than 1 time" do
      assert "AA0011" == @subject.previous("AA0071", 60)
    end

    test "Support map/struct" do
      assert "AA0010" == @subject.previous(%{license_plate: "AA0011"})
    end

    test "Support negative values" do
      assert "AA-00-14" == @subject.previous("AA-00-12", -2)
    end
  end

  describe "Next letters" do
    test "2 digits" do
      assert @subject.next_letters("AA") == "AB"
      assert @subject.next_letters("AJ") == "AL"
      assert @subject.next_letters("AX") == "AZ"
      assert @subject.next_letters("AZ") == "BA"
      assert @subject.next_letters("JZ") == "KA"
      assert @subject.next_letters("KA") == "KB"
      assert @subject.next_letters("KF") == "LA"
      assert @subject.next_letters("ZZ") == "AA"
    end

    test "4 digits" do
      # In the future, some words slangs words will be banned.
      assert @subject.next_letters("AAAA") == "AAAB"
      assert @subject.next_letters("AAAZ") == "AABB"
      assert @subject.next_letters("AAZZ") == "ABAA"
      assert @subject.next_letters("AZZZ") == "BAAB"

      assert @subject.next_letters("AAAJ") == "AAAL"

      # 3 vowels
      assert @subject.next_letters("AICH") == "AICJ"
      assert @subject.next_letters("BAED") == "BAEF"

      assert is_nil(@subject.next_letters("ZZZZ"))
    end

    test "Multiple iterations" do
      assert @subject.next_letters("ABCD", 2) == "ABCF"
    end
  end

  describe "Previous letters" do
    test "2 digits" do
      assert @subject.previous_letters("AB") == "AA"
      assert @subject.previous_letters("AL") == "AJ"
      assert @subject.previous_letters("AZ") == "AX"
      assert @subject.previous_letters("BA") == "AZ"
      assert @subject.previous_letters("KA") == "JZ"
      assert @subject.previous_letters("KB") == "KA"
      assert @subject.previous_letters("LA") == "KF"
      assert @subject.previous_letters("AA") == "ZZ"
    end

    test "4 digits" do
      # In the future, some words slangs words will be banned.
      assert @subject.previous_letters("AAAB") == "AAAA"
      assert @subject.previous_letters("AABA") == "AAAZ"
      assert @subject.previous_letters("ABAA") == "AAZZ"
      assert @subject.previous_letters("BAAA") == "AZZZ"

      assert @subject.previous_letters("AAAL") == "AAAJ"

      # 3 vowels
      assert @subject.previous_letters("AICJ") == "AICH"
      assert @subject.previous_letters("BAEF") == "BAED"

      assert is_nil(@subject.previous_letters("AAAA"))
    end

    test "Multiple iterations" do
      assert @subject.previous_letters("ABCF", 2) == "ABCD"
    end
  end

  describe "get_middle_between/2" do
    test "Same type, same letters, different numbers" do
      assert @subject.get_middle_between("AA-00-01", "AA-00-10") == "AA-00-05"
      assert @subject.get_middle_between("99-90-ZA", "00-10-ZB") == "00-01-ZB"
      assert @subject.get_middle_between("99-90-ZA", "00-02-ZB") == "99-95-ZA"
      assert @subject.get_middle_between("99-98-ZA", "00-10-ZB") == "00-05-ZB"

      assert @subject.get_middle_between("ZB-12-AA", "ZZ-22-XA") == "ZN-17-LN"
    end

    test "Same type, different letters" do
      assert @subject.get_middle_between("AA-00-01", "BZ-00-10") == "BA-00-05"
    end

    test "Different type" do
      assert @subject.get_middle_between("ZZ-99-00", "01-50-AA") == "00-01-AA"
      assert @subject.get_middle_between("99-00-ZZ", "01-AA-50") == "00-AA-01"
      assert @subject.get_middle_between("80-ZZ-00", "AA-05-AA") == "AA-01-AA"
    end

    test "Order doesn't mather" do
      assert @subject.get_middle_between("80-90-GF", "80-55-GF") ==
               @subject.get_middle_between("80-55-GF", "80-90-GF")
    end

    test "Do not generate invalid license plates" do
      assert @subject.get_middle_between("33-ZU-99", "99-ZZ-99") == "00-ZX-01"
      assert @subject.get_middle_between("90-01-ON", "00-40-OP") == "00-01-OP"
      assert @subject.get_middle_between("AA-00-CH", "AA-50-CJ") == "AA-00-CJ"
    end

    test "Invalid license plate provided" do
      assert_raise ArgumentError, "Invalid license plate: 99-ZZ-9", fn ->
        @subject.get_middle_between("33-ZU-99", "99-ZZ-9")
      end
    end
  end

  describe "get_middle_between_letters/2" do
    test "2 Digits" do
      assert @subject.get_middle_between_letters("AA", "BZ") == "BA"
    end

    test "4 Digits" do
      assert @subject.get_middle_between_letters("AAAA", "AABZ") == "AABA"
    end
  end

  describe "convert_letters_to_number" do
    test "Normal values" do
      assert @subject.convert_letters_to_number("AAAA") == 0
      assert @subject.convert_letters_to_number("AAAB") == 1
      assert @subject.convert_letters_to_number("AAAZ") == 25
      assert @subject.convert_letters_to_number("AABA") == 26
      assert @subject.convert_letters_to_number("AABZ") == 51
      assert @subject.convert_letters_to_number("ABAA") == 676
      assert @subject.convert_letters_to_number("BAAA") == 17_576
      assert @subject.convert_letters_to_number("ZZZZ") == :math.pow(26, 4) - 1
    end
  end

  describe "convert_number_to_letters/2" do
    test "Normal values" do
      assert @subject.convert_number_to_letters(0, 4) == "AAAA"
      assert @subject.convert_number_to_letters(1, 4) == "AAAB"
      assert @subject.convert_number_to_letters(26, 4) == "AABA"
      assert @subject.convert_number_to_letters(676, 4) == "ABAA"
      assert @subject.convert_number_to_letters(17_576, 4) == "BAAA"
      assert @subject.convert_number_to_letters(:math.pow(26, 4) - 1, 4) == "ZZZZ"
    end
  end

  describe "fill_earliest" do
    test "Type 1" do
      assert @subject.fill_earliest("A_-__-2_") == "AA-00-20"
      assert @subject.fill_earliest("A_-__-0_") == "AA-00-01"
    end

    test "Type 2" do
      assert @subject.fill_earliest("_9-__-Z_") == "09-00-ZA"
      assert @subject.fill_earliest("_0-__-Z_") == "00-01-ZA"
    end

    test "Type 3" do
      assert @subject.fill_earliest("_9-__-2_") == "09-AA-20"
      assert @subject.fill_earliest("9_-N_-__") == "90-NA-00"
      assert @subject.fill_earliest("0_-N_-__") == "00-NA-01"
    end

    test "Type 4" do
      assert @subject.fill_earliest("AC-__-D_") == "AC-00-DA"
    end

    test "Type 4 - Avoid invalid license plate" do
      assert @subject.fill_earliest("AA-__-B_") == "AA-00-BB"
    end

    test "Multiple type" do
      refute @subject.fill_earliest("A_-9_-__")
    end
  end

  describe "fill_latest" do
    test "Type 1" do
      assert @subject.fill_latest("A_-__-2_") == "AZ-99-29"
    end

    test "Type 2" do
      assert @subject.fill_latest("_9-__-Z_") == "99-99-ZZ"
    end

    test "Type 3" do
      assert @subject.fill_latest("_9-__-2_") == "99-ZZ-29"
      assert @subject.fill_latest("9_-N_-__") == "99-NZ-99"
    end

    test "Type 4" do
      assert @subject.fill_latest("AC-__-D_") == "AC-99-DZ"
    end

    test "Multiple type" do
      refute @subject.fill_latest("A_-9_-__")
    end
  end

  describe "to_partial" do
    test "Replace all 6" do
      assert @subject.to_partial("AB-99-CV", 6) == "__-__-__"
    end

    test "Replace the 3 most significant, type 1" do
      assert @subject.to_partial("AB-33-22", 3) == "AB-3_-__"
    end

    test "Replace the 3 most significant, type 2" do
      assert @subject.to_partial("93-22-AB", 3) == "9_-__-AB"
    end

    test "Replace the 3 most significant, type 3" do
      assert @subject.to_partial("93-AB-22", 3) == "9_-AB-__"
    end

    test "Replace the 3 most significant, type 4" do
      assert @subject.to_partial("AB-99-CV", 3) == "AB-__-C_"
    end
  end

  describe "split/1" do
    test "Should split valid license plate with dash" do
      assert @subject.split("AA-00-01") == ["AA", "00", "01"]
    end

    test "Should split valid license plate without dash" do
      assert @subject.split("AA0001") == ["AA", "00", "01"]
    end

    test "Should raise with invalid format" do
      assert_raise FunctionClauseError, fn ->
        @subject.split("A")
      end
    end
  end
end

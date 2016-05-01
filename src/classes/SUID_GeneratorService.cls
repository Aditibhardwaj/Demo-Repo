//
// (c) 2016 Appirio, Inc.
//
// An apex class that has some methods to generate the SUID from a pool value for contact/account record.
//
// 29th Feb, 2016     Sudhir Kumar Jagetiya       Original
//
public class SUID_GeneratorService {
  // @description: A method that generates SUID based on given pool value.
  // @param: String pool value (7 digit code)
  // @param: String leading digit
  // @return String SUID
  public static String getNextSUID(String poolValue, String leadingDigit) {
    Integer intDigitSum = 0;
    Integer poolValueLength = poolValue.length();
    for(Integer index = 0; index < poolValueLength; index++) {
      String stringDigit = poolValue.subString(index, index+1);
      Integer intDigit = Integer.valueOf(stringDigit);
      intDigitSum += calculateCheckDigit(intDigit, poolValueLength - index);
    }

    Integer intDigitNewSum = intDigitSum;
    while(Math.mod(intDigitNewSum, 10) > 0) {
      // round the sum up to the nearest even multiple of 10
      intDigitNewSum++;
    }

    // get the difference between the original sum and the rounded up sum
    intDigitNewSum = intDigitNewSum - intDigitSum;
    //that's our check digit
    String suId = poolValue + String.valueOf(intDigitNewSum);
    // prepend zeros to the id
    
    for(Integer index = poolValue.length(); index < 9 && suId.length() < 10; index++) {
      suId = leadingDigit + suId;
    }
    return suId;
  }

  // @description: A method that calculate the check digit.
  // @param: Integer digit
  // @param: Integer digit position
  // @return Integer check digit
  private static Integer calculateCheckDigit(Integer digit, Integer position) {
    Integer integerMultiplier, intDigitValue;
    if(Math.mod(position,2) == 0) {
      integerMultiplier = 1;
    } else {
      integerMultiplier = 2;
    }
    intDigitValue = integerMultiplier * digit;
    if(intDigitValue > 9) {
      intDigitValue = intDigitValue + 1 - 10;
    }
    return intDigitValue;
  }

  // @description: A method that vallidate SUID based on check digit.
  // @param: String SUID
  // @param: Boolean is this for account?
  // @return Boolean is this a valid SUID?
  public static Boolean isValidSUIDbasedonCheckDigit(String SUID, Boolean isAccount) {
    // Modified By Aditi B 
    Decimal suid_Numeric = Decimal.valueOf(SUID);
    
    if(suid_Numeric >= 50000000 && suid_Numeric <= 59999999  ) {
      return true;
    }
    //String leadingDigit = isAccount ? '03' : '02';
    String suidWithoutLeadingDigit = SUID.substring(2,SUID.length());
    String generatedSUID = getNextSUID(SUID.substring(2,SUID.length() - 1), '');
    if(suidWithoutLeadingDigit.equalsIgnoreCase(generatedSUID)) {
      return true;
    }
    return false;
  }
}
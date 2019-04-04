var alphabet =   '0123456789ABCDEFGHJKMNPQRTUVWXYZ'
var table = {};
var numTable = [];

var SerialIDGenerator = function(string,currentSerialNumber,number) {
    if(currentSerialNumber > number) {
        console.log("No more serialNumber exists for " + string);
        return
    }
    var serialNumber = toBase32(currentSerialNumber, 6);
    currentSerialNumber += 1;
    return string + serialNumber
};

var makeStrRepeat = function(n,c) {
    var s = "";
    for(var p=0;p<n;p++) {
        s += c;
    }
    return s;
}
/// <summary>
/// Converts the given decimal number to the numeral system with the
/// specified radix (in the range [2, 36]).
/// </summary>
/// <param name="decimalNumber">The number to convert.</param>
/// <param name="radix">The radix of the destination numeral system (in the range [2, 36]).</param>
/// <returns></returns>
var DecimalToArbitrarySystem = function(decimalNumber, radix, table)
{
    var BitsInLong = 64;
    var Digits = table;

    if (radix < 2 || radix > Digits.Length)
         throw new Error("The radix must be >= 2 and <= " + Digits.Length.ToString());

    if (decimalNumber == 0)
        return "0";

    var index = BitsInLong - 1;
    var currentNumber = decimalNumber; //Math.Abs(decimalNumber);
    var outStr = "";

    while (currentNumber != 0)
    {
        var remainder = (currentNumber % radix);
        outStr = Digits[remainder] + outStr;
        currentNumber = Math.floor(currentNumber / radix);
    }

    if (decimalNumber < 0)
    {
        outStr = "-" + outStr;
    }
    return outStr;
}

var ArbitrarySystemToDecimal = function(arbNum, radix, dictionary) {
    var ret = 0;
    var str = new String(arbNum);

    for(var n=0;n<str.length;n++) {
        var c = str.charAt(str.length-n-1);
        var v = dictionary[c];
        if(v > 0)
            ret = ret + v*Math.pow(radix,n);
    }

    return ret;

}


for (var i = 0; i < alphabet.length; i++) {
    table[alphabet[i]] = i
}

var k = Object.keys(table);
for(var n=0;n<k.length;n++)
    numTable[n] = k[n];

var toBase32 = function(number,digits) {
    var baseNumber = DecimalToArbitrarySystem(number,32,numTable);

    while(baseNumber.length != digits) {
        baseNumber = '0' + baseNumber;
    }
    return baseNumber;
}

var fromBase32 = function(base32num) {
    return ArbitrarySystemToDecimal(base32num,32,table);
}

module.exports = {SerialIDGenerator};
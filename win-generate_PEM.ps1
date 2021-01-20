#Author: @bugsam {19/01/2021}

#Powershell that creates an ASN.1 PEM file from RSA parameters
#Reference:
#	[1] https://www.cs.auckland.ac.nz/~pgut001
#	[2] http://luca.ntop.org/Teaching/Appunti/asn1.html

function ByteToHex([array]$hexa){
	$hexa = ( $hexa | ForEach-Object {[System.Convert]::ToString($_,16)})
	for( $i = 0 ; $i -lt $hexa.Length ; $i++ ) {
		if($hexa[$i].Length %2 -eq 1){
			$hexa[$i] = ([string]$hexa[$i]).PadLeft(($hexa[$i].Length+1),'0') 
		}
	}
	$hexa
}

function asnEncoder($tag, $rsaparam){
	$line = [ordered]@{
		"tag" = ByteToHex -hexa $tag;
		"length" = $null;
		"rsaparam" = ByteToHex -hexa $rsaparam;
	}
	
	# ASN.1 INTEGER can be positive, negative or zero;
	# verify whether the MSB of the first byte of value is setted
	# if yes, add a new zeroed byte to do ASN.1 interprets the
	# value as positive
	if ($line['rsaparam'][0] -ge 0x80){
		$line['rsaparam'] = ,(ByteToHex(0)) + $line['rsaparam']
	}
	
	# DER encoding accepts two length formats for values; 
	# for values that contains less than 0x80 bytes, one single byte is
	# used to represent the length. For values greater than 0xFF the MSB
	# of the first byte of length field is set, and the rest of this byte
	# is used to represent the quantity of additional bytes used to represent
	# the length number. The next fields of length represents the length value.
	
	$line['length'] = (ByteToHex -hexa $line['rsaparam'].Length) -split '(.{2})' | Where-Object {$_}
	if ($line['rsaparam'].Length -ge 0x80){
		#first byte of length field, MSB set + number of additional bytes
		#(1000 0000) + (number of additional bytes of Length)
		$payload = ByteToHex($line['length'].Length + 0x80)
		$line['length'] = ,$payload + $line['length']
		$line.values
	} else {
		# if values length is 0xFF or lower
		$line.values
	}
}

#create certificate
$cert = New-SelfSignedCertificate `
	-Subject "DESKTOP-PCPGC7E" `
	-TextExtension @("2.5.29.17={text}DNS=DESKTOP-PCPGC7E&IPAddress=192.168.1.100") `
	-KeySpec Signature `
	-HashAlgorithm SHA256 `
	-KeyExportPolicy Exportable

#certificate
$certPKCS8 = $cert.GetRawCertData();
$certPKCS8_B64 = [Convert]::ToBase64String($certPKCS8,"InsertLineBreaks");

#private key
$key = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($cert);
$_rsamodulus = $key.ExportParameters("true").Modulus;
$_rsapublicexponent = $key.ExportParameters("true").Exponent;
$_rsaprivateexponent = $key.ExportParameters("true").D;
$_rsaprime1 = $key.ExportParameters("true").P;
$_rsaprime2 = $key.ExportParameters("true").Q;
$_rsaexponent1 = $key.ExportParameters("true").DP;
$_rsaexponent2 = $key.ExportParameters("true").DQ;
$_rsacoefficient = $key.ExportParameters("true").InverseQ;

$tag = [byte]0x2;
$keyPKCS8 = [ordered]@{
			"_header" = $null;
			"_rsaalgoident" = ByteToHex(2,1,0,48,13+[Security.Cryptography.CryptoConfig]::EncodeOID("1.2.840.113549.1.1.1")+5,0);
			"_rsaheader" = ByteToHex(2,1,0);
			"_rsamodulus" = asnEncoder -tag $tag -rsaparam $_rsamodulus;
			"_rsapublicexponent" = asnEncoder -tag $tag -rsaparam $_rsapublicexponent;
			"_rsaprivateexponent" = asnEncoder -tag $tag -rsaparam $_rsaprivateexponent;
			"_rsaprime1" = asnEncoder -tag $tag -rsaparam $_rsaprime1;
			"_rsaprim2" = asnEncoder -tag $tag -rsaparam $_rsaprime2;
			"_rsaexponent1" = asnEncoder -tag $tag -rsaparam $_rsaexponent1;
			"_rsaexponent2" = asnEncoder -tag $tag -rsaparam $_rsaexponent2;
			"_rsacoefficient" = asnEncoder -tag $tag -rsaparam $_rsacoefficient;
}

#TODO Header with Length
$length = 0;
$keyPKCS8.values.length | Foreach { $length += $_ }
$tag = 48
$keyPKCS8["_rsaheader"] = ByteToHex($length - $keyPKCS8['_rsaalgoident'].length)
#$keyPKCS8["_header"] = "30"


$keyPKCS8_B64 = [Convert]::ToBase64String($keyPKCS8.values,"InsertLineBreaks");
#createFile
$out = New-Object string[] -ArgumentList 6;
$out[0] = "-----BEGIN PRIVATE KEY-----";
$out[1] = $keyPKCS8_B64;
$out[2] = "-----END PRIVATE KEY-----"

$out[3] = "-----BEGIN CERTIFICATE-----"
$out[4] = $certPKCS8_B64;
$out[5] = "-----END CERTIFICATE-----"

[IO.File]::WriteAllLines("C:\Users\Public\cert.pem",$out)

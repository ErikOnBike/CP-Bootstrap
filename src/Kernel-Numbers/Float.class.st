Class {
	#name : #Float,
	#superclass : #Number,
	#type : #words,
	#classVars : [
		'E',
		'Epsilon',
		'Halfpi',
		'Infinity',
		'Ln10',
		'Ln2',
		'MaxVal',
		'MaxValLn',
		'MinValLogBase2',
		'NaN',
		'NegativeInfinity',
		'NegativeZero',
		'Pi',
		'RadiansPerDegree',
		'Sqrt2',
		'Twopi'
	],
	#category : #'Kernel-Numbers'
}

{ #category : #all }
Float class >> initialize [
	"Float initialize"

	"Constants from Computer Approximations, pp. 182-183:
		Pi = 3.14159265358979323846264338327950288
		Pi/2 = 1.57079632679489661923132169163975144
		Pi*2 = 6.28318530717958647692528676655900576
		Pi/180 = 0.01745329251994329576923690768488612
		2.0 ln = 0.69314718055994530941723212145817657
		2.0 sqrt = 1.41421356237309504880168872420969808"

	Pi := 3.14159265358979323846264338327950288.
	Halfpi := Pi / 2.0.
	Twopi := Pi * 2.0.
	RadiansPerDegree := Pi / 180.0.
	Ln2 := 0.69314718055994530941723212145817657.
	Ln10 := 10.0 ln.
	Sqrt2 := 1.41421356237309504880168872420969808.
	E := 2.718281828459045235360287471353.
	Epsilon := 0.000000000001.	"Defines precision of mathematical functions"
	MaxVal := 1.7976931348623157e308.
	MaxValLn := 709.782712893384.
	MinValLogBase2 := -1074.
	Infinity := MaxVal * MaxVal.
	NegativeInfinity := 0.0 - Infinity.
	NaN := Infinity - Infinity.
	NegativeZero := 1.0 / Infinity negated
]

{ #category : #all }
Float class >> infinity [
	"Answer the constant, Infinity."

	^ Infinity
]

{ #category : #all }
Float class >> pi [
	"Answer the constant, Pi."

	^ Pi
]

{ #category : #all }
Float class >> readFrom: aStream [
	"Answer a new Float as described on the stream, aStream."

	^ (Number readFrom: aStream) asFloat
]

{ #category : #all }
Float >> * aNumber [
	"Primitive. Answer the result of multiplying the receiver by aNumber.
	Fail if the argument is not a Float. Essential. See Object documentation
	whatIsAPrimitive."

	<primitive: 49>
	^ aNumber adaptToFloat: self andSend: #*
]

{ #category : #all }
Float >> + aNumber [
	"Primitive. Answer the sum of the receiver and aNumber. Essential.
	Fail if the argument is not a Float. See Object documentation
	whatIsAPrimitive."

	<primitive: 41>
	^ aNumber adaptToFloat: self andSend: #+
]

{ #category : #all }
Float >> - aNumber [
	"Primitive. Answer the difference between the receiver and aNumber.
	Fail if the argument is not a Float. Essential. See Object documentation
	whatIsAPrimitive."

	<primitive: 42>
	^ aNumber adaptToFloat: self andSend: #-
]

{ #category : #all }
Float >> / aNumber [
	"Primitive. Answer the result of dividing receiver by aNumber.
	Fail if the argument is not a Float. Essential. See Object documentation
	whatIsAPrimitive."

	<primitive: 50>
	aNumber = 0
		ifTrue: [ self error: 'attempt to divide by zero' ].
	^ aNumber adaptToFloat: self andSend: #/
]

{ #category : #all }
Float >> < aNumber [
	"Primitive. Compare the receiver with the argument and return true
	if the receiver is less than the argument. Otherwise return false.
	Fail if the argument is not a Float. Essential. See Object documentation
	whatIsAPrimitive."

	<primitive: 43>
	^ aNumber adaptToFloat: self andSend: #<
]

{ #category : #all }
Float >> <= aNumber [
	"Primitive. Compare the receiver with the argument and return true
	if the receiver is less than or equal to the argument. Otherwise return
	false. Fail if the argument is not a Float. Optional. See Object
	documentation whatIsAPrimitive."

	<primitive: 45>
	^ aNumber adaptToFloat: self andSend: #<=
]

{ #category : #all }
Float >> = aNumber [
	"Primitive. Compare the receiver with the argument and return true
	if the receiver is equal to the argument. Otherwise return false.
	Fail if the argument is not a Float. Essential. See Object documentation
	whatIsAPrimitive."

	<primitive: 47>
	aNumber isNumber
		ifFalse: [ ^ false ].
	^ aNumber adaptToFloat: self andSend: #=
]

{ #category : #all }
Float >> > aNumber [
	"Primitive. Compare the receiver with the argument and return true
	if the receiver is greater than the argument. Otherwise return false.
	Fail if the argument is not a Float. Essential. See Object documentation
	whatIsAPrimitive."

	<primitive: 44>
	^ aNumber adaptToFloat: self andSend: #>
]

{ #category : #all }
Float >> >= aNumber [
	"Primitive. Compare the receiver with the argument and return true
	if the receiver is greater than or equal to the argument. Otherwise return
	false. Fail if the argument is not a Float. Optional. See Object documentation 
	whatIsAPrimitive. "

	<primitive: 46>
	^ aNumber adaptToFloat: self andSend: #>
]

{ #category : #all }
Float >> abs [
	"This is faster than using Number abs."

	self < 0.0
		ifTrue: [ ^ 0.0 - self ]
		ifFalse: [ ^ self ]
]

{ #category : #all }
Float >> absPrintOn: aStream base: base [
	"Print my value on a stream in the given base.  Assumes that my value is strictly
	positive; negative numbers, zero, and NaNs have already been handled elsewhere.
	Based upon the algorithm outlined in:
	Robert G. Burger and R. Kent Dybvig
	Printing Floating Point Numbers Quickly and Accurately
	ACM SIGPLAN 1996 Conference on Programming Language Design and Implementation
	June 1996.
	This version performs all calculations with Floats instead of LargeIntegers, and loses
	about 3 lsbs of accuracy compared to an exact conversion."

	| significantBits fBase exp baseExpEstimate r s mPlus mMinus scale d tc1 tc2 fixedFormat decPointCount |
	self isInfinite
		ifTrue: [ aStream nextPutAll: 'Infinity'.
			^ self ].
	significantBits := 50.	"approximately 3 lsb's of accuracy loss during conversion"
	fBase := base asFloat.
	exp := self exponent.
	baseExpEstimate := (exp * fBase reciprocalLogBase2 - 1.0e-10) ceiling.
	exp >= 0
		ifTrue: [ r := self.
			s := 1.0.
			mPlus := 1.0 timesTwoPower: exp - significantBits.
			mMinus := self significand ~= 1.0
				ifTrue: [ mPlus ]
				ifFalse: [ mPlus / 2.0 ] ]
		ifFalse: [ r := self timesTwoPower: significantBits.
			s := 1.0 timesTwoPower: significantBits.
			mMinus := 1.0 timesTwoPower: (exp max: -1024).
			mPlus := exp = MinValLogBase2 | (self significand ~= 1.0)
				ifTrue: [ mMinus ]
				ifFalse: [ mMinus * 2.0 ] ].
	baseExpEstimate >= 0
		ifTrue: [ s := s * (fBase raisedToInteger: baseExpEstimate).
			exp = 1023
				ifTrue: [ r := r / fBase.
					s := s / fBase.
					mPlus := mPlus / fBase.
					mMinus := mMinus / fBase ]
			"scale down to prevent overflow to Infinity during conversion" ]
		ifFalse: [ exp < -1023
				ifTrue: [ d := (53 * fBase reciprocalLogBase2 - 1.0e-10) ceiling.
					scale := fBase raisedToInteger: d.
					r := r * scale.
					mPlus := mPlus * scale.
					mMinus := mMinus * scale.
					scale := fBase raisedToInteger: (baseExpEstimate + d) negated ]
				ifFalse: [ scale := fBase raisedToInteger: baseExpEstimate negated ].
			"scale up to prevent denorm reciprocals overflowing to Infinity"
			s := s / scale ].
	r + mPlus >= s
		ifTrue: [ baseExpEstimate := baseExpEstimate + 1 ]
		ifFalse: [ s := s / fBase ].
	(fixedFormat := baseExpEstimate between: -3 and: 6)
		ifTrue: [ decPointCount := baseExpEstimate.
			baseExpEstimate <= 0
				ifTrue: [ aStream nextPutAll: ('0.000000' truncateTo: 2 - baseExpEstimate) ] ]
		ifFalse: [ decPointCount := 1 ].
	[ d := (r / s) truncated.
	r := r - (d * s).
	(tc1 := r <= mMinus) | (tc2 := r + mPlus >= s) ]
		whileFalse: [ aStream nextPut: (Character digitValue: d).
			r := r * fBase.
			mPlus := mPlus * fBase.
			mMinus := mMinus * fBase.
			decPointCount := decPointCount - 1.
			decPointCount = 0
				ifTrue: [ aStream nextPut: $. ] ].
	tc2
		ifTrue: [ tc1 not | (tc1 & (r * 2.0 >= s))
				ifTrue: [ d := d + 1 ] ].
	aStream nextPut: (Character digitValue: d).
	decPointCount > 0
		ifTrue: [ decPointCount - 1 to: 1 by: -1 do: [ :i | aStream nextPut: $0 ].
			aStream nextPutAll: '.0' ].
	fixedFormat
		ifFalse: [ aStream nextPut: $e.
			aStream nextPutAll: (baseExpEstimate - 1) printString ]
]

{ #category : #all }
Float >> adaptToInteger: rcvr andSend: selector [
	"If I am involved in arithmetic with an Integer, convert it to a Float."

	^ rcvr asFloat perform: selector with: self
]

{ #category : #all }
Float >> arcCos [
	"Answer the angle in radians."

	^ Halfpi - self arcSin
]

{ #category : #all }
Float >> arcSin [
	"Answer the angle in radians."

	(self < -1.0 or: [ self > 1.0 ])
		ifTrue: [ self error: 'Value out of range' ].
	(self = -1.0 or: [ self = 1.0 ])
		ifTrue: [ ^ Halfpi ]
		ifFalse: [ ^ (self / (1.0 - (self * self)) sqrt) arcTan ]
]

{ #category : #all }
Float >> arcTan [
	"Answer the angle in radians.
	 Optional. See Object documentation whatIsAPrimitive."

	<primitive: 57>
	| theta eps step sinTheta cosTheta |
	self < 0.0
		ifTrue: [ ^ 0.0 - (0.0 - self) arcTan ].	"Newton-Raphson"	"first guess"
	theta := self * Halfpi / (self + 1.0).	"iterate"
	eps := Halfpi * Epsilon.
	step := theta.
	[ step * step > eps ]
		whileTrue: [ sinTheta := theta sin.
			cosTheta := theta cos.
			step := sinTheta * cosTheta - (self * cosTheta * cosTheta).
			theta := theta - step ].
	^ theta
]

{ #category : #all }
Float >> asFloat [
	"Answer the receiver itself."

	^ self
]

{ #category : #all }
Float >> cos [
	"Answer the cosine of the receiver taken as an angle in radians."

	^ (self + Halfpi) sin
]

{ #category : #all }
Float >> degreesToRadians [
	"Answer the receiver in radians. Assumes the receiver is in degrees."

	^ self * RadiansPerDegree
]

{ #category : #all }
Float >> exp [
	"Answer E raised to the receiver power.
	 Optional. See Object documentation whatIsAPrimitive."

	<primitive: 59>
	| base fract correction delta div |
	self < 0.0
		ifTrue: [ ^ self negated exp reciprocal ].	"Taylor series"	"check the special cases"
	self = 0.0
		ifTrue: [ ^ 1 ].
	self abs > MaxValLn
		ifTrue: [ self error: 'exp overflow' ].	"get first approximation by raising e to integer power"
	base := E raisedToInteger: self truncated.	"now compute the correction with a short Taylor series"	"fract will be 0..1, so correction will be 1..E"	"in the worst case, convergance time is logarithmic with 1/Epsilon"
	fract := self fractionPart.
	fract = 0.0
		ifTrue: [ ^ base ].	"no correction required"
	correction := 1.0 + fract.
	delta := fract * fract / 2.0.
	div := 2.0.
	[ delta > Epsilon ]
		whileTrue: [ correction := correction + delta.
			div := div + 1.0.
			delta := delta * fract / div ].
	correction := correction + delta.
	^ base * correction
]

{ #category : #all }
Float >> exponent [
	"Primitive. Consider the receiver to be represented as a power of two
	multiplied by a mantissa (between one and two). Answer with the
	SmallInteger to whose power two is raised. Optional. See Object
	documentation whatIsAPrimitive."

	<primitive: 53>
	| positive |
	self >= 1.0
		ifTrue: [ ^ self floorLog: 2 ].
	self > 0.0
		ifTrue: [ positive := (1.0 / self) exponent.
			self = (1.0 / (1.0 timesTwoPower: positive))
				ifTrue: [ ^ positive negated ]
				ifFalse: [ ^ positive negated - 1 ] ].
	self = 0.0
		ifTrue: [ ^ -1 ].
	^ self negated exponent
]

{ #category : #all }
Float >> floorLog: radix [
	"Answer the floor of the log base radix of the receiver."

	^ (self log: radix) floor
]

{ #category : #all }
Float >> fractionPart [
	"Primitive. Answer a Float whose value is the difference between the 
	receiver and the receiver's asInteger value. Optional. See Object 
	documentation whatIsAPrimitive."

	<primitive: 52>
	^ self - self truncated asFloat
]

{ #category : #all }
Float >> hash [
	"Hash is reimplemented because = is implemented. Both words of the float are used; 8 bits are removed from each end to clear most of the exponent regardless of the byte ordering. (The bitAnd:'s ensure that the intermediate results do not become a large integer.) Slower than the original version in the ratios 12:5 to 2:1 depending on values. (DNS, 11 May, 1997)"

	^ ((self basicAt: 1) bitAnd: 16r00FFFF00)
		+ ((self basicAt: 2) bitAnd: 16r00FFFF00) bitShift: -8
]

{ #category : #all }
Float >> isInfinite [
	"Return true if the receiver is positive or negative infinity."

	^ self = Infinity or: [ self = NegativeInfinity ]
]

{ #category : #all }
Float >> isNaN [
	"simple, byte-order independent test for Not-a-Number"

	^ self ~= self
]

{ #category : #all }
Float >> ln [
	"Answer the natural logarithm of the receiver.
	 Optional. See Object documentation whatIsAPrimitive."

	<primitive: 58>
	| expt n mant x div pow delta sum eps |
	self <= 0.0
		ifTrue: [ self error: 'ln is only defined for x > 0.0' ].	"Taylor series"	"get a rough estimate from binary exponent"
	expt := self exponent.
	n := Ln2 * expt.
	mant := self timesTwoPower: 0 - expt.	"compute fine correction from mantinssa in Taylor series"	"mant is in the range [0..2]"	"we unroll the loop to avoid use of abs"
	x := mant - 1.0.
	div := 1.0.
	pow := delta := sum := x.
	x := x negated.	"x <= 0"
	eps := Epsilon * (n abs + 1.0).
	[ delta > eps ]
		whileTrue: [ div := div + 1.0.
			pow := pow * x.
			delta := pow / div.
			sum := sum + delta.	"pass two: delta is negative"
			div := div + 1.0.
			pow := pow * x.
			delta := pow / div.
			sum := sum + delta ].
	"pass one: delta is positive"
	^ n + sum	"2.718284 ln 1.0"
]

{ #category : #all }
Float >> log [
	"Answer the base 10 logarithm of the receiver."

	^ self ln / Ln10
]

{ #category : #all }
Float >> negated [
	"Answer a Number that is the negation of the receiver."

	^ 0.0 - self
]

{ #category : #all }
Float >> printOn: aStream base: base [
	"Handle sign, zero, and NaNs; all other values passed to absPrintOn:base:"

	self isNaN
		ifTrue: [ aStream nextPutAll: 'NaN'.
			^ self ].	"check for NaN before sign"
	self > 0.0
		ifTrue: [ self absPrintOn: aStream base: base ]
		ifFalse: [ self sign = -1
				ifTrue: [ aStream nextPutAll: '-' ].
			self = 0.0
				ifTrue: [ aStream nextPutAll: '0.0'.
					^ self ]
				ifFalse: [ self negated absPrintOn: aStream base: base ] ]
]

{ #category : #all }
Float >> radiansToDegrees [
	"Answer the receiver in degrees. Assumes the receiver is in radians."

	^ self / RadiansPerDegree
]

{ #category : #all }
Float >> raisedTo: aNumber [
	"Answer the receiver raised to aNumber."

	<primitive: 'primitiveNumberRaisedTo:' module: 'CpSystemPlugin'>

	0.0 = aNumber
		ifTrue: [ ^ 1.0 ].	"special case for 0.0 raisedTo: 0.0"
	^ (self ln * aNumber asFloat) exp
]

{ #category : #all }
Float >> reciprocal [
	^ 1.0 / self
]

{ #category : #all }
Float >> reciprocalLogBase2 [
	"optimized for self = 10, for use in conversion for printing"

	^ self = 10.0
		ifTrue: [ Ln2 / Ln10 ]
		ifFalse: [ Ln2 / self ln ]
]

{ #category : #all }
Float >> rounded [
	"Answer the integer nearest the receiver."

	self >= 0.0
		ifTrue: [ ^ (self + 0.5) truncated ]
		ifFalse: [ ^ (self - 0.5) truncated ]
]

{ #category : #all }
Float >> sign [
	"Answer 1 if the receiver is greater than 0, -1 if less than 0, else 0.
	Handle IEEE-754 negative-zero by reporting a sign of -1"

	self > 0
		ifTrue: [ ^ 1 ].
	(self < 0 or: [ ((self at: 1) bitShift: -31) = 1 ])
		ifTrue: [ ^ -1 ].
	^ 0
]

{ #category : #all }
Float >> significand [
	^ self timesTwoPower: self exponent negated
]

{ #category : #all }
Float >> sin [
	"Answer the sine of the receiver taken as an angle in radians.
	 Optional. See Object documentation whatIsAPrimitive."

	<primitive: 56>
	| sum delta self2 i |
	self < 0.0
		ifTrue: [ ^ 0.0 - (0.0 - self) sin ].	"Taylor series"	"normalize to the range [0..Pi/2]"
	self > Twopi
		ifTrue: [ ^ (self \\ Twopi) sin ].
	self > Pi
		ifTrue: [ ^ 0.0 - (self - Pi) sin ].
	self > Halfpi
		ifTrue: [ ^ (Pi - self) sin ].	"unroll loop to avoid use of abs"
	sum := delta := self.
	self2 := 0.0 - (self * self).
	i := 2.0.
	[ delta > Epsilon ]
		whileTrue: [ delta := delta * self2 / (i * (i + 1.0)).
			i := i + 2.0.
			sum := sum + delta.	"twice"
			delta := delta * self2 / (i * (i + 1.0)).
			i := i + 2.0.
			sum := sum + delta ].
	"once"
	^ sum
]

{ #category : #all }
Float >> sqrt [
	"Answer the square root of the receiver.
	 Optional. See Object documentation whatIsAPrimitive."

	<primitive: 55>
	| exp guess eps delta |
	self <= 0.0
		ifTrue: [ self = 0.0
				ifTrue: [ ^ 0.0 ]
				ifFalse: [ ^ self error: 'sqrt is invalid for x < 0' ] ].	"Newton-Raphson"	"first guess is half the exponent"
	exp := self exponent // 2.
	guess := self timesTwoPower: 0 - exp.	"get eps value"
	eps := guess * Epsilon.
	eps := eps * eps.
	delta := (self - (guess * guess)) / (guess * 2.0).
	[ delta * delta > eps ]
		whileTrue: [ guess := guess + delta.
			delta := (self - (guess * guess)) / (guess * 2.0) ].
	^ guess
]

{ #category : #all }
Float >> tan [
	"Answer the tangent of the receiver taken as an angle in radians."

	^ self sin / self cos
]

{ #category : #all }
Float >> timesTwoPower: anInteger [
	"Primitive. Answer with the receiver multiplied by 2.0 raised
	to the power of the argument.
	Optional. See Object documentation whatIsAPrimitive."

	<primitive: 54>
	anInteger < -29
		ifTrue: [ ^ self * (2.0 raisedToInteger: anInteger) ].
	anInteger < 0
		ifTrue: [ ^ self / (1 bitShift: 0 - anInteger) asFloat ].
	anInteger < 30
		ifTrue: [ ^ self * (1 bitShift: anInteger) asFloat ].
	^ self * (2.0 raisedToInteger: anInteger)
]

{ #category : #all }
Float >> truncated [
	"Answer with a SmallInteger equal to the value of the receiver without 
	its fractional part. The primitive fails if the truncated value cannot be 
	represented as a SmallInteger. In that case, the code below will compute 
	a LargeInteger truncated value.
	Essential. See Object documentation whatIsAPrimitive. "

	<primitive: 51>
	(self isInfinite or: [ self isNaN ])
		ifTrue: [ self error: 'Cannot truncate this number' ].
	self abs < 2.0e16
		ifTrue: [ ^ (self quo: 1073741823.0) * 1073741823
				+ (self rem: 1073741823.0) truncated ]
		ifFalse: [ ^ self error: 'not yet implemented' ]
	"Fastest way when it may not be an integer"
]

{ #category : #all }
Float >> ~= aNumber [
	"Primitive. Compare the receiver with the argument and return true
	if the receiver is not equal to the argument. Otherwise return false.
	Fail if the argument is not a Float. Optional. See Object documentation
	whatIsAPrimitive."

	<primitive: 48>
	^ super ~= aNumber
]

{ #category : #all }
Float >> basicAt: index [
	"Primitive. Assumes receiver is indexable. Answer the value of an
	indexable element in the receiver. Fail if the argument index is not an
	Integer or is out of bounds. Essential. Do not override in a subclass. See
	Object documentation whatIsAPrimitive.

	This version of basicAt: is specifically for floats, answering the most significant
	word for index 1 and the least significant word for index 2.  This alows the VM
	to store floats in whatever order it chooses while it appears to the image that
	they are always in big-endian/PowerPC order."

	<primitive: 38>
	^ super basicAt: index
]

{ #category : #all }
Float >> basicAt: index put: value [
	"Primitive. Assumes receiver is indexable. Store the second argument
	value in the indexable element of the receiver indicated by index. Fail
	if the index is not an Integer or is out of bounds. Or fail if the value is
	not of the right type for this kind of collection. Answer the value that
	was stored. Essential. Do not override in a subclass. See Object
	documentation whatIsAPrimitive.

	This version of basicAt: is specifically for floats, answering the most significant
	word for index 1 and the least significant word for index 2.  This alows the VM
	to store floats in whatever order it chooses while it appears to the image that
	they are always in big-endian/PowerPC order."

	<primitive: 39>
	^ super basicAt: index put: value
]

{ #category : #all }
Float >> cpEncodeWith: anEncoder [
	anEncoder encodeFloat: self
]

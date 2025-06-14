Class {
	#name : #SmallInteger,
	#superclass : #Integer,
	#type : #immediate,
	#category : #'Kernel-Numbers'
}

{ #category : #all }
SmallInteger class >> maxVal [
	"Answer the maximum value for a SmallInteger."

	^ 16r3FFFFFFF
]

{ #category : #all }
SmallInteger class >> minVal [
	"Answer the minimum value for a SmallInteger."

	^ -16r40000000
]

{ #category : #all }
SmallInteger class >> new [
	"SmallIntegers are created as constants or by performing arithmetic."

	self cannotInstantiate
]

{ #category : #all }
SmallInteger >> * aNumber [
	"Primitive. Multiply the receiver by the argument and answer with the
	result if it is a SmallInteger. Fail if the argument or the result is not a
	SmallInteger. Essential. No Lookup. See Object documentation
	whatIsAPrimitive."

	<primitive: 9>
	self = 0
		ifTrue: [ ^ 0 ].	"This eliminates the need for a self=0 check in LargeInteger *"
	^ super * aNumber
]

{ #category : #all }
SmallInteger >> + aNumber [
	"Primitive. Add the receiver to the argument and answer with the result
	if it is a SmallInteger. Fail if the argument or the result is not a
	SmallInteger  Essential  No Lookup. See Object documentation
	whatIsAPrimitive."

	<primitive: 1>
	aNumber isInteger
		ifTrue: [ ^ super + aNumber ].
	^ aNumber adaptToInteger: self andSend: #+
]

{ #category : #all }
SmallInteger >> - aNumber [
	"Primitive. Subtract the argument from the receiver and answer with the
	result if it is a SmallInteger. Fail if the argument or the result is not a
	SmallInteger. Essential. No Lookup. See Object documentation
	whatIsAPrimitive."

	<primitive: 2>
	^ super - aNumber
]

{ #category : #all }
SmallInteger >> / aNumber [
	"Primitive. Divide the receiver by the argument and return the result if the division is exact. Fail if the result is not a whole integer. Fail if the argument is 0 or is not a SmallInteger. Optional. No Lookup. See Object documentation whatIsAPrimitive."

	<primitive: 10>
	aNumber = 0
		ifTrue: [ ^ self error: 'division by 0' ].
	aNumber isSmallInteger
		ifTrue: [ ^ self asFloat / aNumber asFloat ]
		ifFalse: [ ^ super / aNumber ]
]

{ #category : #all }
SmallInteger >> // aNumber [
	"Primitive. Divide the receiver by the argument and answer with the
	result. Round the result down towards negative infinity to make it a
	whole integer. Fail if the argument is 0 or is not a SmallInteger.
	Essential. No Lookup. See Object documentation whatIsAPrimitive. "

	<primitive: 12>
	^ super // aNumber	"Do with quo: if primitive fails"
]

{ #category : #all }
SmallInteger >> < aNumber [
	"Primitive. Compare the receiver with the argument and answer with
	true if the receiver is less than the argument. Otherwise answer false.
	Fail if the argument is not a SmallInteger. Essential. No Lookup. See
	Object documentation whatIsAPrimitive."

	<primitive: 3>
	^ super < aNumber
]

{ #category : #all }
SmallInteger >> <= aNumber [
	"Primitive. Compare the receiver with the argument and answer true if
	the receiver is less than or equal to the argument. Otherwise answer
	false. Fail if the argument is not a SmallInteger. Optional. No Lookup.
	See Object documentation whatIsAPrimitive. "

	<primitive: 5>
	^ super <= aNumber
]

{ #category : #all }
SmallInteger >> = aNumber [
	"Primitive. Compare the receiver with the argument and answer true if
	the receiver is equal to the argument. Otherwise answer false. Fail if the
	argument is not a SmallInteger. Essential. No Lookup. See Object
	documentation whatIsAPrimitive. "

	<primitive: 7>
	^ super = aNumber
]

{ #category : #all }
SmallInteger >> > aNumber [
	"Primitive. Compare the receiver with the argument and answer true if
	the receiver is greater than the argument. Otherwise answer false. Fail if
	the argument is not a SmallInteger. Essential. No Lookup. See Object
	documentation whatIsAPrimitive."

	<primitive: 4>
	^ super > aNumber
]

{ #category : #all }
SmallInteger >> >= aNumber [
	"Primitive. Compare the receiver with the argument and answer true if
	the receiver is greater than or equal to the argument. Otherwise answer
	false. Fail if the argument is not a SmallInteger. Optional. No Lookup.
	See Object documentation whatIsAPrimitive."

	<primitive: 6>
	^ super >= aNumber
]

{ #category : #all }
SmallInteger >> \\ aNumber [
	"Primitive. Take the receiver modulo the argument. The result is the
	remainder rounded towards negative infinity, of the receiver divided by
	the argument Fail if the argument is 0 or is not a SmallInteger. Optional.
	No Lookup. See Object documentation whatIsAPrimitive."

	<primitive: 11>
	^ super \\ aNumber	"Do with // if primitive fails"
]

{ #category : #all }
SmallInteger >> asFloat [
	"Primitive. Answer a Float that represents the value of the receiver.
	Essential. See Object documentation whatIsAPrimitive."

	<primitive: 40>
	self primitiveFailed
]

{ #category : #all }
SmallInteger >> shallowCopy [
	"I am immutable (and not really an object), so answer myself."

	
]

{ #category : #all }
SmallInteger >> basicIdentityHash [
	^ self
]

{ #category : #all }
SmallInteger >> bitAnd: arg [
	"Primitive. Answer an Integer whose bits are the logical OR of the
	receiver's bits and those of the argument, arg.
	Numbers are interpreted as having 2's-complement representation.
	Essential.  See Object documentation whatIsAPrimitive."

	<primitive: 14>
	self >= 0
		ifTrue: [ ^ arg bitAnd: self ].
	^ (self bitInvert bitOr: arg bitInvert) bitInvert
]

{ #category : #all }
SmallInteger >> bitOr: arg [
	"Primitive. Answer an Integer whose bits are the logical OR of the
	receiver's bits and those of the argument, arg.
	Numbers are interpreted as having 2's-complement representation.
	Essential.  See Object documentation whatIsAPrimitive."

	<primitive: 15>
	self >= 0
		ifTrue: [ ^ arg bitOr: self ].
	^ arg < 0
		ifTrue: [ (self bitInvert bitAnd: arg bitInvert) bitInvert ]
		ifFalse: [ (self bitInvert bitClear: arg) bitInvert ]
]

{ #category : #all }
SmallInteger >> bitShift: arg [
	"Primitive. Answer an Integer whose value is the receiver's value shifted
	left by the number of bits indicated by the argument. Negative arguments
	shift right. The receiver is interpreted as having 2's-complement representation.
	Essential.  See Object documentation whatIsAPrimitive."

	<primitive: 17>
	self >= 0
		ifTrue: [ ^ super bitShift: arg ].
	^ arg >= 0
		ifTrue: [ (self negated bitShift: arg) negated ]
		ifFalse: [ (self bitInvert bitShift: arg) bitInvert ]
]

{ #category : #all }
SmallInteger >> bitXor: arg [
	"Primitive. Answer an Integer whose bits are the logical XOR of the
	receiver's bits and those of the argument, arg.
	Numbers are interpreted as having 2's-complement representation.
	Essential.  See Object documentation whatIsAPrimitive."

	<primitive: 16>
	self >= 0
		ifTrue: [ ^ arg bitXor: self ].
	^ arg < 0
		ifTrue: [ self bitInvert bitXor: arg bitInvert ]
		ifFalse: [ (self bitInvert bitXor: arg) bitInvert ]
]

{ #category : #all }
SmallInteger >> digitAt: n [
	"Answer the value of an indexable field in the receiver. Fail if the 
	argument (the index) is not an Integer or is out of bounds."

	n > 4
		ifTrue: [ ^ 0 ].
	self < 0
		ifTrue: [ self = SmallInteger minVal
				ifTrue:
					[ ^ #(0 0 0 64) at: n ].
			"Can't negate minVal -- treat specially"
			^ (0 - self bitShift: (1 - n) * 8) bitAnd: 16rFF ]
		ifFalse: [ ^ (self bitShift: (1 - n) * 8) bitAnd: 16rFF ]
]

{ #category : #all }
SmallInteger >> digitAt: n put: value [
	"Fails. The digits of a small integer can not be modified."

	self error: 'You cannot store in a SmallInteger'
]

{ #category : #all }
SmallInteger >> digitLength [
	"Answer the number of indexable fields in the receiver. This value is the 
	same as the largest legal subscript. Included so that a SmallInteger can 
	behave like a LargePositiveInteger or LargeNegativeInteger."

	(self < 16r100 and: [ self > -16r100 ])
		ifTrue: [ ^ 1 ].
	(self < 16r10000 and: [ self > -16r10000 ])
		ifTrue: [ ^ 2 ].
	(self < 16r1000000 and: [ self > -16r1000000 ])
		ifTrue: [ ^ 3 ].
	^ 4
]

{ #category : #all }
SmallInteger >> hash [
	^ self
]

{ #category : #all }
SmallInteger >> hashMultiply [
	| low |
	low := self bitAnd: 16383.
	^ 16r260D * low
		+
			((16r260D * (self bitShift: -14) + (16r0065 * low) bitAnd: 16383)
				* 16384) bitAnd: 16r0FFFFFFF
]

{ #category : #all }
SmallInteger >> highBit [
	"Answer the index of the high order bit of the receiver, or zero if the receiver is zero. Raise an error if the receiver is negative, since negative integers are defined to have an infinite number of leading 1's in 2's-complement arithmetic."

	| shifted bitNo |
	self < 0
		ifTrue: [ self error: 'highBit is not defined for negative integers' ].
	shifted := self.
	bitNo := 0.
	[ shifted < 16 ]
		whileFalse: [ shifted := shifted bitShift: -4.
			bitNo := bitNo + 4 ].
	[ shifted = 0 ]
		whileFalse: [ shifted := shifted bitShift: -1.
			bitNo := bitNo + 1 ].
	^ bitNo
]

{ #category : #all }
SmallInteger >> identityHash [
	^ self hashMultiply
]

{ #category : #all }
SmallInteger >> isSmallInteger [
	^ true
]

{ #category : #all }
SmallInteger >> printOn: aStream base: b [
	"Refer to the comment in Integer|printOn:base:."

	"self maxVal printStringBase: 2"

	| digitsInReverse x i |
	self < 0
		ifTrue: [ aStream nextPut: $-.
			^ self negated printOn: aStream base: b ].
	b = 10
		ifFalse: [ b printOn: aStream.
			aStream nextPut: $r ].
	digitsInReverse := Array new: 32.
	x := self.
	i := 0.
	[ x >= b ]
		whileTrue: [ digitsInReverse at: (i := i + 1) put: x \\ b.
			x := x // b ].
	digitsInReverse at: (i := i + 1) put: x.
	[ i > 0 ]
		whileTrue: [ aStream nextPut: (Character digitValue: (digitsInReverse at: i)).
			i := i - 1 ]
]

{ #category : #all }
SmallInteger >> quo: aNumber [
	"Primitive. Divide the receiver by the argument and answer with the result. Round the result down towards zero to make it a whole integer. Fail if the argument is 0 or is not a MSmallInteger. Optional. See Object documentation whatIsAPrimitive."

	<primitive: 13>
	aNumber = 0
		ifTrue: [ ^ self error: 'Attempt to divide by zero' ].
	aNumber class isSmallInteger
		ifTrue: [ self primitiveFailed ]
		ifFalse: [ ^ super quo: aNumber ]
]

{ #category : #all }
SmallInteger >> ~= aNumber [
	"Primitive. Compare the receiver with the argument and answer true if
	the receiver is not equal to the argument. Otherwise answer false. Fail if
	the argument is not a SmallInteger. Essential. No Lookup. See Object
	documentation whatIsAPrimitive."

	<primitive: 8>
	^ super ~= aNumber
]

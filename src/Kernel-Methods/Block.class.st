Class {
	#name : #Block,
	#superclass : #Object,
	#instVars : [
		'outerContext',
		'startpc',
		'nargs'
	],
	#category : #'Kernel-Methods'
}

{ #category : #all }
Block >> asContext [
	"Create a MethodContext that is ready to execute self.  Assumes self takes no args (if it does the args will be nil)"

	^ self asContextWithSender: nil
]

{ #category : #all }
Block >> asContextWithSender: aContext [
	"Inner private support method for evaluation.  Do not use unless you know what you're doing."

	^ (MethodContext newForMethod: outerContext method)
		setSender: aContext
			receiver: outerContext receiver
			method: outerContext method
			closure: self
			startpc: startpc;
		privRefresh
]

{ #category : #all }
Block >> forkAt: priority [

	^ self forkAt: priority name: nil
]

{ #category : #all }
Block >> forkAt: priority named: aString [

	"Do not answer forked process, because it might not be running yet leading to unexpected behavior accessing it"

	(Process forContext: self asContext priority: priority)
		name: aString ;
		resume.
	^ nil
]

{ #category : #all }
Block >> home [
	^ outerContext home
]

{ #category : #all }
Block >> methodReturnContext [
	^ outerContext methodReturnContext
]

{ #category : #all }
Block >> ifError: errorHandlerBlock [
	"Evaluate the block represented by the receiver. If an error occurs the given handler block is evaluated. The handler block can be either a zero- or two-argument block; if the latter, then the error message and receiver are supplied to it as parameters. Answer the value returned by the handler block if the receiver gets an error."

	"Warning: The receiver should not contain an explicit return since that would leave an obsolete error handler hanging around."

	"Examples:
		[1 whatsUpDoc] ifError: [:err :rcvr | ^ 'huh?'].
		[1 whatsUpDoc] ifError: ['huh'].
		[1 / 0] ifError: [:err :rcvr |
			'division by 0' = err
				ifTrue: [^ Float infinity]
				ifFalse: [self error: err]]
"
	^ self on: Error do: [ :ex |
		errorHandlerBlock cull: ex description cull: ex receiver]
]

{ #category: #all }
Block >> on: exception do: handlerAction [
	"Evaluate the receiver in the scope of an exception handler.
	The following primitive is just a marker used to find the error handling context. 
	See MethodContext>>#isHandlerOrSignalingContext. "
	<primitive: 199>  
	^ self value
]

{ #category : #all }
Block >> method [
	^ self home method
]

{ #category : #all }
Block >> numArgs [
	^ nargs
]

{ #category : #all }
Block >> numCopiedValues [
	"Answer the number of copied values of the receiver.  Since these are
	 stored in the receiver's indexable fields this is the receiver's basic size.
	 Primitive. Answer the number of indexable variables in the receiver. 
	 This value is the same as the largest legal subscript."

	^ self basicSize
]

{ #category : #all }
Block >> outerContext [
	^ outerContext
]

{ #category : #all }
Block >> receiver [
	^ outerContext receiver
]

{ #category : #all }
Block >> startpc [
	^startpc
]

{ #category : #all }
Block >> value [
	"Evaluate this block without any arguments."

	<primitive: 201>
	^ self valueWithArguments: #()
]

{ #category : #all }
Block >> value: arg [
	"Evaluate this block with one argument."

	<primitive: 202>
	^ self valueWithArguments: (Array with: arg)
]

{ #category : #all }
Block >> value: arg1 value: arg2 [
	"Evaluate this block with two arguments."

	<primitive: 203>
	^ self valueWithArguments: (Array with: arg1 with: arg2)
]

{ #category : #all }
Block >> valueWithArguments: anArray [
	"Primitive. Evaluate the block represented by the receiver. The argument is an Array whose elements are the arguments for the block. Fail if the length of the Array is not the same as the the number of arguments that the block was expecting. Fail if the block is already being executed. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 206>
	anArray size = nargs
		ifTrue: [ self
				error: 'Attempt to evaluate a block that is already being evaluated.' ]
		ifFalse: [ self
				error: 'This block requires ' , nargs printString , ' arguments.' ]
]

{ #category : #all }
Block >> cull: anArg [
	^nargs = 0 
		ifTrue: [self value]
		ifFalse: [self value: anArg]
]

{ #category : #all }
Block >> cull: firstArg cull: secondArg [
	^nargs = 0 
		ifTrue: [self value]
		ifFalse: [
			nargs = 1
				ifTrue: [ self value: firstArg]
				ifFalse: [ self value: firstArg value: secondArg ] ]
]

{ #category : #all }
Block >> repeat [
	[ self value. true ] whileTrue: [ ]
]

{ #category : #all }
Block >> ensure: aBlock [
	"Evaluate a termination block after evaluating the receiver, regardless of
	 whether the receiver's evaluation completes.  N.B.  This method is *not*
	 implemented as a primitive.  Primitive 198 always fails.  The VM uses prim
	 198 in a context's method as the mark for an ensure:/ifCurtailed: activation."

	| complete returnValue |
	<primitive: 198>
	returnValue := self valueNoContextSwitch.
	complete ifNil:[
		complete := true.
		aBlock value.
	].
	^ returnValue
]

{ #category : #all }
Block >> ifCurtailed: aBlock [
	"Evaluate the receiver with an abnormal termination action.
	 Evaluate aBlock only if execution is unwound during execution
	 of the receiver.  If execution of the receiver finishes normally do
	 not evaluate aBlock.  N.B.  This method is *not* implemented as a
	 primitive.  Primitive 198 always fails.  The VM uses prim 198 in a
	 context's method as the mark for an ensure:/ifCurtailed: activation."
	| complete result |
	<primitive: 198>
	result := self valueNoContextSwitch.
	complete := true.
	^result
]

{ #category : #all }
Block >> valueNoContextSwitch [
	"An exact copy of BlockClosure>>value except that this version will not preempt
	 the current process on block activation if a higher-priority process is runnable.
	 Primitive. Essential."
	<primitive: 221>
	^ self valueWithArguments: #()
]

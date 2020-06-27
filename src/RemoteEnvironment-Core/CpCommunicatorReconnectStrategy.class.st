Class {
	#name : #CpCommunicatorReconnectStrategy,
	#superclass : #Object,
	#category : #'RemoteEnvironment-Core'
}

{ #category : #all }
CpCommunicatorReconnectStrategy >> shouldReconnect: aCommunicator [

	"There is no usable connection for the Communicator.
	Answer whether the specified Communicator should reconnect.
	Subclasses should override this behavior."

	^ true
]

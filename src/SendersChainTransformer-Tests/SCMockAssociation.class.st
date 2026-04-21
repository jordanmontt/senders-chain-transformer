Class {
	#name : 'SCMockAssociation',
	#superclass : 'Association',
	#category : 'SendersChainTransformer-Tests-Utilities',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Utilities'
}

{ #category : 'automatically-generated' }
SCMockAssociation class >> key: newKey value: newValue [
	"Answer an instance of me with the arguments as the key and value of
	the association."

	^self basicNew key: newKey value: newValue
]

{ #category : 'accessing' }
SCMockAssociation >> key: aKey value: anObject [
	"Store the arguments as the variables of the receiver."

	key := aKey.
	value := anObject
]

Class {
	#name : 'SCAnotherMockClass',
	#superclass : 'Object',
	#instVars : [
		'aDictionary'
	],
	#category : 'Senders-Chain-Transformer-Tests',
	#package : 'Senders-Chain-Transformer-Tests'
}

{ #category : 'accessing - token' }
SCAnotherMockClass >> bar [

	aDictionary at: 1 put: 3
]

{ #category : 'initialization' }
SCAnotherMockClass >> initialize [

	super initialize.
	aDictionary := Dictionary new
]

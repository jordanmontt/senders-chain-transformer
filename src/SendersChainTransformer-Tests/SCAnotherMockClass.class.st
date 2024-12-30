Class {
	#name : 'SCAnotherMockClass',
	#superclass : 'Object',
	#instVars : [
		'aDictionary'
	],
	#category : 'SendersChainTransformer-Tests-Mocking',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Mocking'
}

{ #category : 'accessing - token' }
SCAnotherMockClass >> bar [

	SCDefaultFixture new.
	aDictionary at: 1 put: 3
]

{ #category : 'initialization' }
SCAnotherMockClass >> initialize [

	super initialize.
	aDictionary := Dictionary new
]

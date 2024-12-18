Class {
	#name : 'SCAnotherMockClass',
	#superclass : 'Object',
	#instVars : [
		'aDictionary'
	],
	#category : 'SendersChainTransformer-Tests',
	#package : 'SendersChainTransformer-Tests'
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

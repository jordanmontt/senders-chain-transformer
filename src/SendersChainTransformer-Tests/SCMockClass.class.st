Class {
	#name : 'SCMockClass',
	#superclass : 'Object',
	#instVars : [
		'anotherFakeClass'
	],
	#category : 'SendersChainTransformer-Tests-Mocking',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Mocking'
}

{ #category : 'accessing' }
SCMockClass >> foo [

	anotherFakeClass := SCAnotherMockClass new.
	anotherFakeClass bar
]

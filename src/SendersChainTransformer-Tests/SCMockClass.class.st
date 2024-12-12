Class {
	#name : 'SCMockClass',
	#superclass : 'Object',
	#instVars : [
		'anotherFakeClass'
	],
	#category : 'SendersChainTransformer-Tests',
	#package : 'SendersChainTransformer-Tests'
}

{ #category : 'accessing' }
SCMockClass >> foo [

	anotherFakeClass := SCAnotherMockClass new.
	anotherFakeClass bar
]

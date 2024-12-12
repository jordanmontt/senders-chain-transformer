Class {
	#name : 'SCMockClass',
	#superclass : 'Object',
	#instVars : [
		'anotherFakeClass'
	],
	#category : 'Senders-Chain-Transformer-Tests',
	#package : 'Senders-Chain-Transformer-Tests'
}

{ #category : 'accessing' }
SCMockClass >> foo [

	anotherFakeClass := SCAnotherMockClass new.
	anotherFakeClass bar
]

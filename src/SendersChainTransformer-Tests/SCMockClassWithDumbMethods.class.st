Class {
	#name : 'SCMockClassWithDumbMethods',
	#superclass : 'Object',
	#instVars : [
		'anotherFakeClass',
		'aDictionary'
	],
	#category : 'SendersChainTransformer-Tests-Utilities',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Utilities'
}

{ #category : 'api' }
SCMockClassWithDumbMethods >> addOccupant: anObject [

	(self theOccupants at: anObject class name ifAbsentPut: [ OrderedCollection new ]) add: anObject
]

{ #category : 'api' }
SCMockClassWithDumbMethods >> at: key ifAbsentPut: aBlock [

	^ self at: key ifAbsent: [ self at: key put: aBlock value ]
]

{ #category : 'api' }
SCMockClassWithDumbMethods >> bar [

	Object new.
	aDictionary at: 1 put: 3
]

{ #category : 'api' }
SCMockClassWithDumbMethods >> binaryMethod [

	self foo: self ,, 1 andBar: 0
]

{ #category : 'api' }
SCMockClassWithDumbMethods >> foo [

	anotherFakeClass := SCMockClassWithDumbMethods new.
	anotherFakeClass bar
]

{ #category : 'initialization' }
SCMockClassWithDumbMethods >> initialize [

	super initialize.
	aDictionary := Dictionary new
]

{ #category : 'api' }
SCMockClassWithDumbMethods >> theMethodWithBlock [

	| myVar |
	myVar anotherThing: [ Dictionary new ].
	1 = myVar something: [
		Object new. "Do not change this"
		SCMockClassWithDumbMethods new "this is the selector to change" ].
	^ self
]

{ #category : 'api' }
SCMockClassWithDumbMethods >> theOccupants [

	^ Dictionary new
]

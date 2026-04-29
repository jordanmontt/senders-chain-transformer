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

{ #category : 'automatically-generated' }
SCMockClassWithDumbMethods class >> createTenured [

	^ self newTenured
]

{ #category : 'automatically-generated' }
SCMockClassWithDumbMethods class >> fromHexString: aColorHex [
	"Returns a color instance from HEX (6 element elements)."

	"(Color fromHexString: 'FFFFFF')>>> (Color white) "

	| green red blue alpha hexString |
	hexString := aColorHex withoutPrefix: '#'.
	red := (Integer readFrom: (hexString first: 2) base: 16) / 255.
	green := (Integer readFrom: (hexString copyFrom: 3 to: 4) base: 16) / 255.
	blue := (Integer readFrom: (hexString copyFrom: 5 to: 6) base: 16) / 255.

	alpha := hexString size = 8
		ifFalse: [ 1.0 ]
		ifTrue: [ (Integer readFrom: (hexString copyFrom: 7 to: 8) base: 16) / 255 ].

	^ self r: red g: green b: blue alpha: alpha
]

{ #category : 'automatically-generated' }
SCMockClassWithDumbMethods class >> newTenured [

	^ self basicNewTenured initialize
]

{ #category : 'automatically-generated' }
SCMockClassWithDumbMethods class >> with: firstObject with: secondObject with: thirdObject with: fourthObject [
	"Answer a new instance of me, containing only the three arguments as
	elements."

	| newCollection |
	newCollection := self new: 4.
	newCollection at: 1 put: firstObject.
	newCollection at: 2 put: secondObject.
	newCollection at: 3 put: thirdObject.
	newCollection at: 4 put: fourthObject.
	^newCollection
]

{ #category : 'api' }
SCMockClassWithDumbMethods >> @ anObject [

	2 + 2.
	self addOccupant: anObject
]

{ #category : 'automatically-generated' }
SCMockClassWithDumbMethods >> addOccupant: anObject [

	(self theOccupants at: anObject class name ifAbsentPut: [ OrderedCollection new ]) add: anObject
]

{ #category : 'api' }
SCMockClassWithDumbMethods >> at: key ifAbsentPut: aBlock [

	^ self at: key ifAbsent: [ self at: key put: aBlock value ]
]

{ #category : 'automatically-generated' }
SCMockClassWithDumbMethods >> availableProbes [

	| colorString color |

	^ (Pragma allNamed: #probeNamed:color: in: self) collect: [ :pragma |
		colorString := pragma arguments second.

		color := [ Object perform: colorString asSymbol ]
			onErrorDo: [ Color fromHexString: colorString ].

		Object new
			name: pragma arguments first;
			color: color;
			method: pragma method;
			yourself ].
]

{ #category : 'automatically-generated' }
SCMockClassWithDumbMethods >> bar [

	Object new.
	aDictionary at: 1 put: 3
]

{ #category : 'api' }
SCMockClassWithDumbMethods >> binaryMethod [

	self foo: self ,, 1 andBar: 0
]

{ #category : 'automatically-generated' }
SCMockClassWithDumbMethods >> foo [

	anotherFakeClass := SCMockClassWithDumbMethods new.
	anotherFakeClass bar
]

{ #category : 'initialization' }
SCMockClassWithDumbMethods >> initialize [

	super initialize.
	aDictionary := SCMockDictionary new
]

{ #category : 'automatically-generated' }
SCMockClassWithDumbMethods >> pepe [

	self new
]

{ #category : 'automatically-generated' }
SCMockClassWithDumbMethods >> tata [

	^ self uaua
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

{ #category : 'automatically-generated' }
SCMockClassWithDumbMethods >> toto [

	self basicNew
]

{ #category : 'automatically-generated' }
SCMockClassWithDumbMethods >> uaua [

	self toto.
	self pepe
]

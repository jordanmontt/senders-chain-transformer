"
A CodeTransformationMergerTest is a test class for testing the behavior of CodeTransformationMerger
"
Class {
	#name : 'CodeTransformationMergerTest',
	#superclass : 'TestCase',
	#instVars : [
		'codeMerger'
	],
	#category : 'SendersChainTransformer-Tests-Tests',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Tests'
}

{ #category : 'helpers' }
CodeTransformationMergerTest >> compile: aSourceCode [

	^ OpalCompiler new
		  source: aSourceCode;
		  compile
]

{ #category : 'helpers' }
CodeTransformationMergerTest >> merge: modifications [

	^ codeMerger mergeCompiledMethods: modifications
]

{ #category : 'running' }
CodeTransformationMergerTest >> setUp [

	super setUp.

	codeMerger := CodeTransformationsMerger new
]

{ #category : 'tests - binary selectors' }
CodeTransformationMergerTest >> testMergeBinarySelectorTransformations [

	| modification1 modification2 result expected |
	modification1 := self
		compile: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ key _pretenured_941934174_SHwyb: aBlock value ]'.
	modification2 := self
		compile: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ key -- aBlock value ]'.

	result := self merge: { modification2. modification1 }.
	expected := self compile: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ key _pretenured_941934174_SHwyb: aBlock value ]'.

	self assert: result parseTree equals: expected parseTree
]

{ #category : 'tests - merging' }
CodeTransformationMergerTest >> testMergeGetterAndSetterTransformations [

	| transformation1 transformation2 result expected |
	transformation1 := self
		compile: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ]'.
	transformation2 := self
		compile: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self at: key put: aBlock value ]'.

	result := self merge: { transformation2. transformation1 }.
	expected := self
		compile: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ]'.

	self assert: result parseTree equals: expected parseTree
]

{ #category : 'tests - merging' }
CodeTransformationMergerTest >> testMergeGetterTransformationsWithSetterBlock [

	| getterModification setterModification result expected |
	getterModification := self
		compile: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ifAbsent: [ self doSomething ] ]'.
	setterModification := self
		compile: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]'.

	result := self merge: { getterModification. setterModification }.
	expected := self compile: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ifAbsent: [ self doSomething ] ]'.

	self assert: result parseTree equals: expected parseTree
]

{ #category : 'tests - merging' }
CodeTransformationMergerTest >> testMergeMultipleTransformationsFromBothDirections [

	| modification1 modification2 modification3 result expected |
	modification1 := self
		compile: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ifAbsent: [ self doSomething ] ]'.
	modification2 := self
		compile: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]'.
	modification3 := self
		compile: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self _pretenured_76688_doSomething ] ]'.

	result := self merge: { modification1. modification2. modification3 }.
	expected := self compile: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ifAbsent: [ self _pretenured_76688_doSomething ] ]'.

	self assert: result parseTree equals: expected parseTree
]

{ #category : 'tests - integration' }
CodeTransformationMergerTest >> testMergeRealWorldTransformations [

	| transformation1 transformation2 transformedMethod expectedMethod |

	transformation1 := self compile:
	'addOccupant: anObject
	(self theOccupants
		 _pretenured_286021818_at: anObject class name
		 ifAbsentPut: [ OrderedCollection new ]) add: anObject'.
	transformation2 := self compile:
	'addOccupant: anObject
	(self theOccupants
		 at: anObject class name
		 ifAbsentPut: [ OrderedCollection newTenured ]) add: anObject'.

	transformedMethod := self merge: { transformation1. transformation2 }.

	expectedMethod := self compile:
	'addOccupant: anObject
		(self theOccupants _pretenured_286021818_at: anObject class name
		ifAbsentPut: [ OrderedCollection newTenured ])
	add: anObject'.

	self assert: expectedMethod parseTree equals: transformedMethod parseTree
]

{ #category : 'tests - merging' }
CodeTransformationMergerTest >> testMergeSetterTransformationsWithGetterBlock [

	| setterModification getterModification result expected |
	setterModification := self
		compile: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]'.
	getterModification := self
		compile: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self _pretenured_76688_doSomething ] ]'.

	result := self merge: { setterModification. getterModification }.
	expected := self compile: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self _pretenured_76688_doSomething ] ]'.

	self assert: result parseTree equals: expected parseTree
]

{ #category : 'tests - single transformation' }
CodeTransformationMergerTest >> testSingleTransformationKeepsSourceUnchanged [

	| modification result |
	modification := self
		compile: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ifAbsent: [ self doSomething ] ]'.

	result := self merge: { modification }.

	self assert: result parseTree equals: modification parseTree
]

{ #category : 'tests - single transformation' }
CodeTransformationMergerTest >> testTransformedBlockResultDoesNotAffectOuter [

	| modification result |
	modification := self
		compile: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self _pretenured_76688_doSomething ] ]'.

	result := self merge: { modification }.

	self assert: result parseTree equals: modification parseTree
]

{ #category : 'tests - single transformation' }
CodeTransformationMergerTest >> testTransformedGetterDoesNotAffectTransformedSetter [

	| modification result |
	modification := self
		compile: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]'.

	result := self merge: { modification }.

	self assert: result parseTree equals: modification parseTree
]

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

{ #category : 'tests' }
CodeTransformationMergerTest >> compile: aSourceCode [

	^ OpalCompiler new
		  source: aSourceCode;
		  compile
]

{ #category : 'running' }
CodeTransformationMergerTest >> setUp [

	super setUp.

	codeMerger := CodeTransformationsMerger new
]

{ #category : 'tests' }
CodeTransformationMergerTest >> testMergeCodeTransformationsIn [

	| modification1 modification2 result expected |
	modification1 := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ]';
			compile.
	modification2 := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self at: key put: aBlock value ]';
			compile.

	result := codeMerger mergeCompiledMethods: { modification2. modification1 }.
	expected := (OpalCompiler new
			 source: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ]';
			 compile).
	self assert: result parseTree equals: expected parseTree
]

{ #category : 'tests' }
CodeTransformationMergerTest >> testMergeCodeTransformationsIn2 [

	| modification1 result |
	modification1 := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ifAbsent: [ self doSomething ] ]';
			compile.
	result := codeMerger mergeCompiledMethods: { modification1 }.
	self assert: result parseTree equals: modification1 parseTree
]

{ #category : 'tests' }
CodeTransformationMergerTest >> testMergeCodeTransformationsIn3 [

	| modification2 result |
	modification2 := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]';
			compile.
	result := codeMerger mergeCompiledMethods: { modification2 }.
	self assert: result parseTree equals: modification2 parseTree
]

{ #category : 'tests' }
CodeTransformationMergerTest >> testMergeCodeTransformationsIn4 [

	| modification3 result |
	modification3 := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self _pretenured_76688_doSomething ] ]';
			compile.
	result := codeMerger mergeCompiledMethods: { modification3 }.
	self assert: result parseTree equals: modification3 parseTree
]

{ #category : 'tests' }
CodeTransformationMergerTest >> testMergeCodeTransformationsInBinaryTransformedSelector [

	| modification1 modification2 result expected |
	modification1 := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ key _pretenured_941934174_SHwyb: aBlock value ]';
			compile.
	modification2 := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ key -- aBlock value ]';
			compile.

	result := codeMerger mergeCompiledMethods: { modification2. modification1 }.
	expected := (OpalCompiler new
			 source: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ key _pretenured_941934174_SHwyb: aBlock value ]';
			 compile).
	self assert: result parseTree equals: expected parseTree
]

{ #category : 'tests' }
CodeTransformationMergerTest >> testMergeCodeTransformationsInOtherExample [

	| modification1 modification2 result expected |
	modification1 := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ifAbsent: [ self doSomething ] ]';
			compile.
	modification2 := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]';
			compile.
	result := codeMerger mergeCompiledMethods: { modification1. modification2 }.
	expected := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ifAbsent: [ self doSomething ] ]';
			compile.
	self assert: result parseTree equals: expected parseTree 
]

{ #category : 'tests' }
CodeTransformationMergerTest >> testMergeCodeTransformationsInOtherLongerExample [

	| modification3 modification2 result expected |
	modification2 := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]';
			compile.
	modification3 := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self _pretenured_76688_doSomething ] ]';
			compile.
	
	result := codeMerger mergeCompiledMethods: { modification2. modification3 }.
	expected := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self _pretenured_76688_doSomething ] ]';
			compile.
	
	self assert: result parseTree equals: result parseTree
]

{ #category : 'tests' }
CodeTransformationMergerTest >> testMergeCodeTransformationsInSeveralChanges [

	| modification1 modification2 modification3 result expected |
	modification1 := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ifAbsent: [ self doSomething ] ]';
			compile.
	modification2 := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self doSomething ] ]';
			compile.
	modification3 := OpalCompiler new
			source: 'at: key ifAbsentPut: aBlock
	^ self at: key ifAbsent: [ self at: key put: aBlock value ifAbsent: [ self _pretenured_76688_doSomething ] ]';
			compile.
	
	result := codeMerger mergeCompiledMethods: { modification1 . modification2 . modification3 }.
	expected := OpalCompiler new
			compile: 'at: key ifAbsentPut: aBlock
	^ self _pretenured_76688_at: key ifAbsent: [ self _pretenured_76688_at: key put: aBlock value ifAbsent: [ self _pretenured_76688_doSomething ] ]';
	compile.
	
	self assert: result parseTree equals: expected parseTree
]

{ #category : 'tests' }
CodeTransformationMergerTest >> testNew [

	| transformation1 transformation2 transformedMethod expectedMethod codeTransformer aCompiledBlock|

	codeTransformer := CallSiteTransformer new.
	
	transformation1 := codeTransformer transformMessageSend: (IllMethodWithOffset method: SCMockClassWithDumbMethods >> #addOccupant: offset: 81).
	
	aCompiledBlock := ((SCMockClassWithDumbMethods >> #addOccupant:) literals at: 4) compiledBlock.
	transformation2 := codeTransformer transformMessageSend: (IllMethodWithOffset method: aCompiledBlock offset: 26).

	transformedMethod := codeMerger mergeCompiledMethods: { transformation1. transformation2 }.

	expectedMethod := String streamContents: [ :aStream |
		                  aStream << 'addOccupant: anObject
		(self theOccupants _pretenured_' << codeTransformer selectorMaker randomPrefix asString
		                  << '_at: anObject class name
		ifAbsentPut: [ OrderedCollection newTenured ])
	add: anObject' ].
	expectedMethod := OpalCompiler new source: expectedMethod; compile.

	self assert: expectedMethod parseTree equals: transformedMethod parseTree
]

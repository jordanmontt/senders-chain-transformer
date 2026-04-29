Class {
	#name : 'AllocationSitesPretenurerTransformationPlusMergingTest',
	#superclass : 'TestCase',
	#instVars : [
		'pretenurator'
	],
	#category : 'SendersChainTransformer-Tests-Tests',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
AllocationSitesPretenurerTransformationPlusMergingTest >> preparePath: aListOfMethods [

	| messageSend pc current next |
	^ aListOfMethods allButLast collectWithIndex: [ :e :i |
			current := e.
			next := aListOfMethods at: i + 1.

			messageSend := current ast allChildren detect: [ :node | node isMessage and: [ node selector = next selector ] ].
			pc := messageSend methodNode firstPcForNode: messageSend.

			IllMethodWithOffset method: current offset: pc ]
]

{ #category : 'running' }
AllocationSitesPretenurerTransformationPlusMergingTest >> setUp [

	super setUp.

	pretenurator := AllocationSitesPretenurer new
]

{ #category : 'tests' }
AllocationSitesPretenurerTransformationPlusMergingTest >> testMergeCodeTransformationsProblematic [

	"| bar toto result originalCaller expected pepe |
	originalCaller := OpalCompiler new source: 'foo self bar'; compile.
	bar := OpalCompiler new source: 'bar self toto. self pepe'; compile.
	toto := OpalCompiler new source: 'toto ^ 42'; compile.
	pepe := OpalCompiler new source: 'pepe ^ 24'; compile.

	path1 := self preparePath: { originalCaller. bar . toto }.
	path2 := self preparePath: { originalCaller . bar . pepe }.
	
	result := codeMerger mergeTransformedCompiledMethods: path1.
	result := codeMerger mergeTransformedCompiledMethods: path2."
]

{ #category : 'tests' }
AllocationSitesPretenurerTransformationPlusMergingTest >> testTransformationsForTwoAllocationSitesInSameMethod [

	| transformedInitialCaller transformedSenders mergedSender atIfAbsentSender atPutSender keyValueSender block |

	pretenurator compilePretenuredPathsFrom: SCPathFixture new cormasPaths.

	transformedInitialCaller := pretenurator transformedCallSites first.
	transformedSenders := pretenurator transformedSenders.

	self assert: pretenurator transformedCallSites size equals: 1.
	self assert: transformedSenders size equals: 4.

	self assert: (transformedInitialCaller sourceCode includesSubstring: 'OrderedCollection newTenured').
	self assert: ((transformedInitialCaller sourceNodeForPC: 81) selector includesSubstring: #_pretenured_).
	self assert: ((transformedInitialCaller sourceNodeForPC: 81) selector includesSubstring: #_at:).

	mergedSender := transformedSenders detect: [ :m | m selector includesSubstring: #at:ifAbsentPut: ].
	atIfAbsentSender := transformedSenders detect: [ :m | m selector includesSubstring: #at:ifAbsent: ].
	atPutSender := transformedSenders detect: [ :m | m selector includesSubstring: #at:put: ].
	keyValueSender := transformedSenders detect: [ :m | m selector includesSubstring: #key:value: ].

	"Merged sender assertions"
	block := mergedSender literals first.
	self assert: ((mergedSender sourceNodeForPC: 48) selector includesSubstring: '_pretenured_').
	self assert: ((block sourceNodeForPC: 29) selector includesSubstring: '_pretenured_').

	"Other senders assertions"
	self assert: (atIfAbsentSender sourceNodeForPC: 54) selector equals: #value.
	self assert: ((atPutSender sourceNodeForPC: 82) selector includesSubstring: #_pretenured_).
	self assert: (keyValueSender sourceNodeForPC: 42) selector equals: #basicNewTenured
]

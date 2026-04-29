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
AllocationSitesPretenurerTransformationPlusMergingTest >> testMergeCodeTransformationsDataFrame [

	| transformedInitialCaller transformedSenders mergedSender |

	pretenurator compilePretenuredPathsFrom: SCPathFixture new dataFramePaths.
	
	transformedInitialCaller := pretenurator transformedCallSites first.
	transformedSenders := pretenurator transformedSenders.

	self assert: pretenurator transformedCallSites size equals: 1.
	self assert: transformedSenders size equals: 10.

	mergedSender := transformedSenders detect: [ :m | m selector includesSubstring: #readNextRecord ].
	
	self assert: (mergedSender sourceCode includesSubstring: '_pretenured_').
	self assert: (mergedSender sourceCode includesSubstring: '_recordClassNew:').
	self assert: (mergedSender sourceCode includesSubstring: '_readNextRecordWithoutFieldAccessors:')
]

{ #category : 'tests' }
AllocationSitesPretenurerTransformationPlusMergingTest >> testMergeCodeTransformationsProblematic [

	| transformedInitialCaller transformedSenders mergedSender totoSender pepeSender |

	pretenurator compilePretenuredPathsFrom: SCPathFixture new fooPaths.
	
	transformedInitialCaller := pretenurator transformedCallSites first.
	transformedSenders := pretenurator transformedSenders.

	self assert: pretenurator transformedCallSites size equals: 1.
	self assert: transformedSenders size equals: 3.

	self assert: (transformedInitialCaller sourceCode includesSubstring: '_pretenured_').
	self assert: (transformedInitialCaller sourceCode includesSubstring: '_uaua').

	mergedSender := transformedSenders detect: [ :m | m selector includesSubstring: #uaua ].
	totoSender := transformedSenders detect: [ :m | m selector includesSubstring: #toto ].
	pepeSender := transformedSenders detect: [ :m | m selector includesSubstring: #pepe ].

	self assert: (mergedSender sourceCode includesSubstring: '_pretenured_').
	self assert: (mergedSender sourceCode includesSubstring: '_toto').
	self assert: (mergedSender sourceCode includesSubstring: '_pepe').

	self assert: (totoSender sourceCode includesSubstring: 'self basicNewTenured').
	self assert: (pepeSender sourceCode includesSubstring: 'self newTenured')
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

	block := mergedSender literals first.
	self assert: ((mergedSender sourceNodeForPC: 48) selector includesSubstring: '_pretenured_').
	self assert: ((block sourceNodeForPC: 29) selector includesSubstring: '_pretenured_').

	self assert: (atIfAbsentSender sourceNodeForPC: 54) selector equals: #value.
	self assert: ((atPutSender sourceNodeForPC: 82) selector includesSubstring: #_pretenured_).
	self assert: (keyValueSender sourceNodeForPC: 42) selector equals: #basicNewTenured
]

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

{ #category : 'helpers' }
AllocationSitesPretenurerTransformationPlusMergingTest >> senderWithSelectorSubstring: aSubstring in: transformedSenders [

	^ transformedSenders detect: [ :m | m selector includesSubstring: aSubstring ]
]

{ #category : 'running' }
AllocationSitesPretenurerTransformationPlusMergingTest >> setUp [

	super setUp.

	pretenurator := AllocationSitesPretenurer new
]

{ #category : 'tests' }
AllocationSitesPretenurerTransformationPlusMergingTest >> testMergeCodeTransformationsDataFrameExample [

	| mergedSender |
	pretenurator compilePretenuredPathsFrom: SCPathFixture new dataFramePaths.

	self assert: pretenurator transformedCallSites size equals: 1.
	self assert: pretenurator transformedSenders size equals: 10.
	
	mergedSender := self senderWithSelectorSubstring: #readNextRecord in: pretenurator transformedSenders.

	#('_pretenured_' '_recordClassNew:' '_readNextRecordWithoutFieldAccessors:') do: [ :substring |
			self assert: (mergedSender sourceCode includesSubstring: substring) ]
]

{ #category : 'tests' }
AllocationSitesPretenurerTransformationPlusMergingTest >> testMergeCodeTransformationsFooExample [

	| mergedSender totoSender pepeSender |

	pretenurator compilePretenuredPathsFrom: SCPathFixture new fooPaths.

	self assert: pretenurator transformedCallSites size equals: 1.
	self assert: pretenurator transformedSenders size equals: 3.

	self assert: (pretenurator transformedCallSites first sourceCode includesSubstring: '_pretenured_').
	self assert: (pretenurator transformedCallSites first sourceCode includesSubstring: '_uaua').

	mergedSender := self senderWithSelectorSubstring: #uaua in: pretenurator transformedSenders.
	totoSender := self senderWithSelectorSubstring: #toto in: pretenurator transformedSenders.
	pepeSender := self senderWithSelectorSubstring: #pepe in: pretenurator transformedSenders.

	self assert: (mergedSender sourceCode includesSubstring: '_pretenured_').
	self assert: (mergedSender sourceCode includesSubstring: '_toto').
	self assert: (mergedSender sourceCode includesSubstring: '_pepe').

	self assert: (totoSender sourceCode includesSubstring: 'self basicNewTenured').
	self assert: (pepeSender sourceCode includesSubstring: 'self newTenured')
]

{ #category : 'tests' }
AllocationSitesPretenurerTransformationPlusMergingTest >> testTransformationsForTwoAllocationSitesInSameMethod [

	| mergedSender atIfAbsentSender atPutSender keyValueSender block |

	pretenurator compilePretenuredPathsFrom: SCPathFixture new cormasPaths.

	self assert: pretenurator transformedCallSites size equals: 1.
	self assert: pretenurator transformedSenders size equals: 4.

	self assert: (pretenurator transformedCallSites first sourceCode includesSubstring: 'OrderedCollection newTenured').
	self assert: ((pretenurator transformedCallSites first sourceNodeForPC: 81) selector includesSubstring: #_pretenured_).
	self assert: ((pretenurator transformedCallSites first sourceNodeForPC: 81) selector includesSubstring: #_at:).

	mergedSender := self senderWithSelectorSubstring: #at:ifAbsentPut: in: pretenurator transformedSenders.
	atIfAbsentSender := self senderWithSelectorSubstring: #at:ifAbsent: in: pretenurator transformedSenders.
	atPutSender := self senderWithSelectorSubstring: #at:put: in: pretenurator transformedSenders.
	keyValueSender := self senderWithSelectorSubstring: #key:value: in: pretenurator transformedSenders.

	block := mergedSender literals first.
	self assert: ((mergedSender sourceNodeForPC: 48) selector includesSubstring: '_pretenured_').
	self assert: ((block sourceNodeForPC: 29) selector includesSubstring: '_pretenured_').

	self assert: (atIfAbsentSender sourceNodeForPC: 54) selector equals: #value.
	self assert: ((atPutSender sourceNodeForPC: 82) selector includesSubstring: #_pretenured_).
	self assert: (keyValueSender sourceNodeForPC: 42) selector equals: #basicNewTenured
]

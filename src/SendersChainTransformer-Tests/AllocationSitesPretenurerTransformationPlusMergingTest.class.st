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
AllocationSitesPretenurerTransformationPlusMergingTest >> senderWithSelector: aSubstring in: transformedSenders [

	^ transformedSenders detect: [ :m | m selector = aSubstring ]
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
	
	mergedSender := self senderWithSelector: #_pretenured_readNextRecord in: pretenurator transformedSenders.

	#('recordClassNew:' 'readNextRecordWithoutFieldAccessors:') do: [ :substring |
			self assert: (mergedSender sourceCode includesSubstring: ('_pretenured_' , substring)) ]
]

{ #category : 'tests' }
AllocationSitesPretenurerTransformationPlusMergingTest >> testMergeCodeTransformationsFooExample [

	| mergedSender totoSender pepeSender |

	pretenurator compilePretenuredPathsFrom: SCPathFixture new fooPaths.

	self assert: pretenurator transformedCallSites size equals: 1.
	self assert: pretenurator transformedSenders size equals: 3.

	self assert: (pretenurator transformedCallSites first sourceCode includesSubstring: '_pretenured_uaua').

	mergedSender := self senderWithSelector: #_pretenured_uaua in: pretenurator transformedSenders.
	totoSender := self senderWithSelector: #_pretenured_toto in: pretenurator transformedSenders.
	pepeSender := self senderWithSelector: #_pretenured_pepe in: pretenurator transformedSenders.

	self assert: (mergedSender sourceCode includesSubstring: '_pretenured_toto').
	self assert: (mergedSender sourceCode includesSubstring: '_pretenured_pepe').

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
	self assert: (pretenurator transformedCallSites first sourceNodeForPC: 81) selector equals: #_pretenured_at:ifAbsentPut:.

	mergedSender := self senderWithSelector: #_pretenured_at:ifAbsentPut: in: pretenurator transformedSenders.
	atIfAbsentSender := self senderWithSelector: #_pretenured_at:ifAbsent: in: pretenurator transformedSenders.
	atPutSender := self senderWithSelector: #_pretenured_at:put: in: pretenurator transformedSenders.
	keyValueSender := self senderWithSelector: #_pretenured_key:value: in: pretenurator transformedSenders.

	block := mergedSender literals first.
	self assert: (mergedSender sourceNodeForPC: 48) selector equals: #_pretenured_at:ifAbsent:.
	self assert: (block sourceNodeForPC: 29) selector equals: #_pretenured_at:put:.

	self assert: (atIfAbsentSender sourceNodeForPC: 54) selector equals: #value.
	self assert: ((atPutSender sourceNodeForPC: 82) selector includesSubstring: #_pretenured_key:value:).
	self assert: (keyValueSender sourceNodeForPC: 42) selector equals: #basicNewTenured
]

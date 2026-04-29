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

{ #category : 'running' }
AllocationSitesPretenurerTransformationPlusMergingTest >> setUp [

	super setUp.

	pretenurator := AllocationSitesPretenurer new
]

{ #category : 'assertions' }
AllocationSitesPretenurerTransformationPlusMergingTest >> assertMergedSenderIn: transformedSenders containsAll: substrings [

	| mergedSender |

	mergedSender := transformedSenders detect: [ :m | m selector includesSubstring: #readNextRecord ].

	substrings do: [ :substring |
		self assert: (mergedSender sourceCode includesSubstring: substring)
	]
]

{ #category : 'helpers' }
AllocationSitesPretenurerTransformationPlusMergingTest >> senderWithSelectorSubstring: aSubstring in: transformedSenders [

	^ transformedSenders detect: [ :m | m selector includesSubstring: aSubstring ]
]

{ #category : 'tests' }
AllocationSitesPretenurerTransformationPlusMergingTest >> testMergeCodeTransformationsDataFrame [

	| result |

	result := pretenurator compilePretenuredPathsFrom: SCPathFixture new dataFramePaths.

	self assert: result transformedCallSites size equals: 1 description: 'Should have one transformed call site'.
	self assert: result transformedSenders size equals: 10 description: 'Should have ten transformed senders'.

	self assertMergedSenderIn: result transformedSenders containsAll: #('_pretenured_' '_recordClassNew:' '_readNextRecordWithoutFieldAccessors:')
]

{ #category : 'tests' }
AllocationSitesPretenurerTransformationPlusMergingTest >> testMergeCodeTransformationsProblematic [

	| result mergedSender totoSender pepeSender |

	result := pretenurator compilePretenuredPathsFrom: SCPathFixture new fooPaths.

	self assert: result transformedCallSites size equals: 1 description: 'Should have one transformed call site'.
	self assert: result transformedSenders size equals: 3 description: 'Should have three transformed senders'.

	self assert: (result transformedCallSites first sourceCode includesSubstring: '_pretenured_').
	self assert: (result transformedCallSites first sourceCode includesSubstring: '_uaua').

	mergedSender := self senderWithSelectorSubstring: #uaua in: result transformedSenders.
	totoSender := self senderWithSelectorSubstring: #toto in: result transformedSenders.
	pepeSender := self senderWithSelectorSubstring: #pepe in: result transformedSenders.

	self assert: (mergedSender sourceCode includesSubstring: '_pretenured_').
	self assert: (mergedSender sourceCode includesSubstring: '_toto').
	self assert: (mergedSender sourceCode includesSubstring: '_pepe').

	self assert: (totoSender sourceCode includesSubstring: 'self basicNewTenured').
	self assert: (pepeSender sourceCode includesSubstring: 'self newTenured')
]

{ #category : 'tests' }
AllocationSitesPretenurerTransformationPlusMergingTest >> testTransformationsForTwoAllocationSitesInSameMethod [

	| result mergedSender atIfAbsentSender atPutSender keyValueSender block |

	result := pretenurator compilePretenuredPathsFrom: SCPathFixture new cormasPaths.

	self assert: result transformedCallSites size equals: 1 description: 'Should have one transformed call site'.
	self assert: result transformedSenders size equals: 4 description: 'Should have four transformed senders'.

	self assert: (result transformedCallSites first sourceCode includesSubstring: 'OrderedCollection newTenured').
	self assert: ((result transformedCallSites first sourceNodeForPC: 81) selector includesSubstring: #_pretenured_).
	self assert: ((result transformedCallSites first sourceNodeForPC: 81) selector includesSubstring: #_at:).

	mergedSender := self senderWithSelectorSubstring: #at:ifAbsentPut: in: result transformedSenders.
	atIfAbsentSender := self senderWithSelectorSubstring: #at:ifAbsent: in: result transformedSenders.
	atPutSender := self senderWithSelectorSubstring: #at:put: in: result transformedSenders.
	keyValueSender := self senderWithSelectorSubstring: #key:value: in: result transformedSenders.

	block := mergedSender literals first.
	self assert: ((mergedSender sourceNodeForPC: 48) selector includesSubstring: '_pretenured_').
	self assert: ((block sourceNodeForPC: 29) selector includesSubstring: '_pretenured_').

	self assert: (atIfAbsentSender sourceNodeForPC: 54) selector equals: #value.
	self assert: ((atPutSender sourceNodeForPC: 82) selector includesSubstring: #_pretenured_).
	self assert: (keyValueSender sourceNodeForPC: 42) selector equals: #basicNewTenured
]

Class {
	#name : 'MaxLiveSizeTest',
	#superclass : 'TestCase',
	#instVars : [
		'mockedAllocationGraph'
	],
	#category : 'SendersChainTransformer-Tests-Tests',
	#package : 'SendersChainTransformer-Tests',
	#tag : 'Tests'
}

{ #category : 'running' }
MaxLiveSizeTest >> setUp [

	super setUp.

	mockedAllocationGraph := MockedClassForMaxSizeTest new
]

{ #category : 'tests' }
MaxLiveSizeTest >> testMaxLiveSize [

	| analyzer|
	analyzer := AllocationSiteClassificator new
			allocationGraph: mockedAllocationGraph;
			startTime: mockedAllocationGraph initialTime;
			endTime: mockedAllocationGraph endTime;
			yourself.

	self assert: analyzer maxLiveSize equals: 140 "j and m are the only alive objects at point 13 of the timeline. J weights 100 bytes and m 40"
]

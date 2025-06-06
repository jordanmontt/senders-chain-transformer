"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestSendersChainTransformer',
	#superclass : 'PackageManifest',
	#category : 'SendersChainTransformer-Manifest',
	#package : 'SendersChainTransformer',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestSendersChainTransformer class >> ruleCollectionProtocolRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#AllocationGraph #identifyAllocationSitesUsing: #false)) #'2025-06-06T10:06:11.08545+02:00') )
]

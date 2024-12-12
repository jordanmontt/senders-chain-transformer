"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestSendersChainTransformer',
	#superclass : 'PackageManifest',
	#category : 'Senders-Chain-Transformer-Manifest',
	#package : 'Senders-Chain-Transformer',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestSendersChainTransformer class >> ruleNobodyShouldSendMethodDictV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGPackageDefinition #(#'Senders-Chain-Transformer')) #'2024-12-12T16:14:31.077108+01:00') )
]

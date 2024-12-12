"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestSendersChainTransformerTests',
	#superclass : 'PackageManifest',
	#category : 'Senders-Chain-Transformer-Tests-Manifest',
	#package : 'Senders-Chain-Transformer-Tests',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestSendersChainTransformerTests class >> ruleNobodyShouldSendMethodDictV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGPackageDefinition #(#'Senders-Chain-Transformer-Tests')) #'2024-12-12T16:32:34.837696+01:00') )
]

params.coverageFile = ''
params.outputFile = ''
params.upload = 'false'
params.mergeDistance =''
params.outputDir = ''


nextflow.enable.dsl=2


process uploadData {
  label "small_slurm"
   tag 'upload'
    
    input:
    path bedFile

    
    script:
    if (params.upload){
        println "upload files"
        """
        current_date=`date +'%d_%m_%y_%H'`

        ${params.DBXCLI} put $bedFile $params.uploadDir/\$current_date/$bedFile
        """
    }
    else{
        println "not uploading"
        """
            echo "not uploading"
        """
    }
}

process mergeChrom {
    label "small_slurm"
    tag "merge_${chrom}"
    
    input:
    tuple val(chrom), path(gnomAD), path(gnomADtbi)
    path file_list
    

    output:
    path "${chrom}.tsv"
    
    script:
    outputName = "${chrom}"  
    """
    source ${params.VENV}
    merge_chrom.py ${chrom} ${gnomAD} ${outputName} ${file_list.join(' ')}
    """
}



process createCoverage {
    label "medium_slurm"
    tag "createCoverage_${output.replace('.bed','')}"
    
    input:
        val chrom
        val distance
        path coverageFile

     output:
        path "${output}"
    
    script:
    output="${chrom}.bed"
    """
    create_coverage.sh -g ${coverageFile} -c ${chrom} -o ${output} -d ${distance} -t '.'
    echo "done coverage for ${chrom}"
    """
    
}



process mergeCoverage {

    publishDir params.outDir , mode: 'copy' 
    
    label "small_slurm"
    tag "mergeCoverage"
    
    input:
    path chromCoverage
    val output 

    output:
    path "${output}"
    
    script:
    """
    merge_bed_files.sh -s ${chromCoverage.join(' ')} -o ${output}
    """
}

workflow {
    // using default parameters if they werent provided
    if (params.mergeDistance == ''){
        mergeDistance = params.default_merge_distance
    } else {
        mergeDistance = params.mergeDistance
    }
    date = new Date().format('yyyy_MM_dd_HH')
    if (params.outputDir == ''){
        params.outDir = "${params.output_dir}/${date}"
    } else {
        params.outDir = "${params.outputDir}/${date}"
        
    }

    coverageFile = file(params.coverageFile)
    
    if (params.outputFile == ''){
        outputFile = "${coverageFile.baseName}.bed"
    } else {
        outputFile = params.outputFile
        
    }
     
    
    log.info """
        V C F - T S V   P I P E L I N E 
         coverageFile: ${coverageFile}
         outputFile: ${params.outDir}/${outputFile}
         mergeDistance: ${mergeDistance}
         """
         .stripIndent()
    
    println "starting"
    chromosomes = []
    numChromosomes = 23

    for (int i = 1; i <= numChromosomes; i++) {
        if (i == 23) {
            chromosomes.add("chrX")
            chromosomes.add("chrY")
        } else {
            chromosomes.add("chr" + i)
        }
    }
    
    chromChannel = Channel.from(chromosomes)
    // create coverage file for each chromosome seperatly
    coverage = createCoverage(chromChannel, mergeDistance, coverageFile)
    merged = mergeCoverage(coverage.collect(), outputFile )

    // upload the data to the dropbox, if params.upload == true
    uploadData(merged)  

}

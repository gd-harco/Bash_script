#!/bin/bash

#echo -e "\e[police;couleur_texte;couleur_fondm..."

#echo a green text
function echoGreen {
    echo -e "\033[32m$1\033[0m"
}
function echoRed {
    echo -e "\033[31m$1\033[0m"
}

function echolightbluebackground {
    echo -e "\033[104m$1\033[0m"
}

function askForFolder {
    echolightbluebackground "Veuillez glisser-déposer le dossier à valider et appuyer sur entrer"
    read -r FOLDER
    # FOLDER=/Users/muttedit/Desktop/CULTURA
    checkForFolder
}



#Checking that the file is a folder
function checkForFolder {
    if [ -d "$FOLDER" ]
    then
        echoGreen "Merci pour le dossier"
    else
        echoRed "Oupsi doupsi, tu n'as pas compris ? J'ai demandé un dossier. Tu peux recommencer ?"
        askForFolder
    fi
}

#Checking if the folder contains the required folders
function checkForRequiredFolders {
    if [ -d "$FOLDER/PHOTOS AMBIANCE" ] ; then
        AMBIANCE=true
    else
        AMBIANCE=false
    fi

    if [ -d "$FOLDER/PHOTOS TUTO" ] ; then
        TUTO=true
    else
        TUTO=false
    fi
    if [ $TUTO == true ] && [ $AMBIANCE == true ] ; then
        echoGreen "Les dossiers requis sont bien présents"
        echolightbluebackground "Appuyer sur entrer pour continuer"
        read -r
    elif [ $TUTO == false ] && [ $AMBIANCE == true ] ; then 
        echoRed "Le dossier 'PHOTOS TUTO' est introuvable"
        echolightbluebackground "Appuyer sur entrer pour quitter"
        read -r 
        exit
    elif [ $TUTO == true ] && [ $AMBIANCE == false ] ; then
        echoRed "Le dossier 'PHOTOS AMBIANCE' est introuvable"
        echolightbluebackground "Appuyer sur entrer pour quitter"
        read -r 
        exit
    else
        echoRed "Les dossiers requis sont absent"
        echolightbluebackground "Appuyer sur entrer pour quitter"
        read -r
        exit
    fi  
}

function verifyAmbianceFolder {
    echo "Vérification de la présence des dossiers HD et WEB"
    if [ -d "$PWD/HD" ] ; then
        echoGreen "Le dossier HD est présent"
    else
        echoRed "Le dossier HD est absent"
        echolightbluebackground "Appuyer sur entrer pour quitter"
        read -r
        exit
    fi
    if [ -d "$PWD/WEB" ] ; then
        echoGreen "Le dossier WEB est présent"
    else
        echoRed "Le dossier WEB est absent"
        echolightbluebackground "Appuyer sur entrer pour quitter"
        read -r
        exit
    fi
}

function verifyAmbianceHDFolderContent {
    currentFolder=$PWD
    for entry in "$currentFolder"/*
    do
        if [[ $entry == *.jpg ]] || [[ $entry == *.png ]] || [[ $entry == *.jpeg ]] || [[ $entry == *.tiff ]]  ; then
            echo "Vérification de $(basename "$entry") en cours"
            name=$(basename "$entry")
            name=$(echo "$name" | rev | cut -d '-' -f1 | rev)
            name=$(echo "$name" | cut -d '.' -f1)
            else
            echoRed "ERREUR ! Le fichier "$(basename "$entry")" n'est pas une image"
            echolightbluebackground "Appuyer sur ENTRER pour continuer"
            read -r
        fi
        HEIGHT=0
        WIDTH=0
        case $name in
            carre)
                getImageDimensions
                verifySquareDimensions
                ;;
            paysage)
                getImageDimensions
                verifyLandscapeDimensions
                ;;
            portrait)
                getImageDimensions
                verifyPortraitDimensions
                ;;
        esac
    done
    if [ $VALIDLANDSCAPE == true ] && [ $VALIDPORTRAIT == true ] && [ $VALIDSQUARE == true ] ; then
        echoGreen "Le dossier Ambiance/HD est valide"
        echolightbluebackground "Appuyer sur ENTRER pour continuer"
        read -r
    else
        echoRed "Le dossier Ambiance/HD n'est pas valide"
        echolightbluebackground "Appuyer sur ENTRER pour continuer"
        read -r
        INVALIDFOLDER=$((INVALIDFOLDER + 1))
    fi
}

function getImageDimensions {
    HEIGHTFULL=$(sips -g pixelHeight "$entry")
    HEIGHT=$(echo $HEIGHTFULL | cut -d ':' -f2) 
    WIDTHFULL=$(sips -g pixelWidth "$entry")
    WIDTH=$(echo $WIDTHFULL | cut -d ':' -f2)
}

function verifySquareDimensions {
    if  [[ "$WIDTH" -eq "3096" ]] && [[ "$HEIGHT" -eq "3096" ]]; then
        echoGreen "L'image $(basename "$entry") est valide"
        VALIDSQUARE=true
    else
        echoRed "ERREUR ! L'image $(basename "$entry") n'est pas valide"
        echoRed "Dimension de l'image : "$WIDTH"x"$HEIGHT""
        echoRed "Requis : 3096x3096"
        echolightbluebackground "Appuyer sur ENTRER pour continuer"
        read -r
    fi

}

function verifyLandscapeDimensions {
    if [[ "$HEIGHT" -eq "3629" ]] && [[ "$WIDTH" -eq "5443" ]] ; then
        echoGreen "L'image $(basename "$entry") est valide"
        VALIDLANDSCAPE=true
    else
        echoRed "ERREUR ! L'image $(basename "$entry") n'est pas valide"
        echoRed "Dimension de l'image : "$WIDTH"x"$HEIGHT""
        echoRed "Requis : 5443x3629"
        echolightbluebackground "Appuyer sur ENTRER pour continuer"
        read -r
    fi
}

function verifyPortraitDimensions {
    if [[ "$HEIGHT" -eq "5568" ]] && [[ "$WIDTH" -eq "3712" ]] ; then
        echoGreen "L'image $(basename "$entry") est valide"
        VALIDPORTRAIT=true

    else
        echoRed "ERREUR ! L'image $(basename "$entry") n'est pas valide"
        echoRed "Dimension de l'image : "$WIDTH"x"$HEIGHT""
        echoRed "Requis : 3712x5568"
        echolightbluebackground "Appuyer sur ENTRER pour continuer"
        read -r
    fi    
}

function verifyAmbianceWEBFolderContent {
    currentFolder=$PWD
    for entry in "$currentFolder"/*
    do
        if [[ $entry == *.jpg ]] || [[ $entry == *.png ]] || [[ $entry == *.jpeg ]] || [[ $entry == *.tiff ]]  ; then
            echo "Vérification de $(basename "$entry") en cours"
            name=$(basename "$entry")
            name=$(echo "$name" | rev | cut -d '-' -f1 | rev)
            name=$(echo "$name" | cut -d '.' -f1)
            else
            echoRed "ERREUR ! Le fichier "$(basename "$entry")" n'est pas une image"
            echolightbluebackground "Appuyer sur ENTRER pour continuer"
            read -r
        fi
        HEIGHT=0
        WIDTH=0
        case $name in
            carre)
                getImageDimensions
                verifySquare1080Dimensions
                ;;
            header)
                getImageDimensions
                verifyHeaderDimensions
                ;;
            paysage)
                getImageDimensions
                verifyLandscape1080Dimensions
                ;;
            portrait)
                getImageDimensions
                verifyPortrait720Dimensions
                ;;
            vignette)
                getImageDimensions
                verifyVignetteDimensions
                ;;
            instagram)
                getImageDimensions
                verifyInstagramDimensions
                ;;
            tuto)
                getImageDimensions
                verifyTutoDimensions
                ;;
        esac
    done
    if [ $VALIDSQUARE1080 == true ] && [ $VALIDHEADER == true ] && [ $VALIDLANDSCAPE1080 == true ] && [ $VALIDPORTRAIT720 == true ] && [ $VALIDSQUARE1080 == true ] ; then
        echoGreen "Le dossier Ambiance/WEB est valide"
        echolightbluebackground "Appuyer sur ENTRER pour continuer"
        read -r
    else
        echoRed "Le dossier Ambiance/WEB n'est pas valide"
        echolightbluebackground "Appuyer sur ENTRER pour continuer"
        read -r
        INVALIDFOLDER=$((INVALIDFOLDER + 1))
    fi

}

function verifySquare1080Dimensions {
    if  [[ "$WIDTH" -eq "1080" ]] && [[ "$HEIGHT" -eq "1080" ]] ; then
        echoGreen "L'image $(basename "$entry") est valide"
        VALIDSQUARE1080=true
    else
        echoRed "ERREUR ! L'image $(basename "$entry") n'est pas valide"
        echoRed "Dimension de l'image : "$WIDTH"x"$HEIGHT""
        echoRed "Requis : 1080x1080"
        echolightbluebackground "Appuyer sur ENTRER pour continuer"
        read -r
    fi
}

function verifyHeaderDimensions {
    if  [[ "$WIDTH" -eq "2000" ]] &&[[ "$HEIGHT" -eq "500" ]] ; then
        echoGreen "L'image $(basename "$entry") est valide"
        VALIDHEADER=true
    else
        echoRed "ERREUR ! L'image $(basename "$entry") n'est pas valide"
        echoRed "Dimension de l'image : "$WIDTH"x"$HEIGHT""
        echoRed "Requis : 2000x500"
        echolightbluebackground "Appuyer sur ENTRER pour continuer"
        read -r
        WRONGDIMENSIONS=$((WRONGDIMENSIONS + 1))
    fi
}

function verifyLandscape1080Dimensions {
    if  [[ "$WIDTH" -eq "1080" ]] && [[ "$HEIGHT" -eq "720" ]] ; then
        echoGreen "L'image $(basename "$entry") est valide"
        VALIDLANDSCAPE1080=true
    else
        echoRed "ERREUR ! L'image $(basename "$entry") n'est pas valide"
        echoRed "Dimension de l'image : "$WIDTH"x"$HEIGHT""
        echoRed "Requis : 1080x720"
        echolightbluebackground "Appuyer sur ENTRER pour continuer"
        read -r
    fi
}

function verifyPortrait720Dimensions {
    if  [[ "$WIDTH" -eq "720" ]] && [[ "$HEIGHT" -eq "1080" ]] ; then
        echoGreen "L'image $(basename "$entry") est valide"
        VALIDPORTRAIT720=true
    else
        echoRed "ERREUR ! L'image $(basename "$entry") n'est pas valide"
        echoRed "Dimension de l'image : "$WIDTH"x"$HEIGHT""
        echoRed "Requis : 720x1080"
        echolightbluebackground "Appuyer sur ENTRER pour continuer"
        read -r
    fi
}

function verifyVignetteDimensions {
    if  [[ "$WIDTH" -eq "1027" ]]&& [[ "$HEIGHT" -eq "578" ]] ; then
        echoGreen "L'image $(basename "$entry") est valide"
        VALIDVIGNETTE=true
    else
        echoRed "ERREUR ! L'image $(basename "$entry") n'est pas valide"
        echoRed "Dimension de l'image : "$WIDTH"x"$HEIGHT""
        echoRed "Requis : 578x1027"
        echolightbluebackground "Appuyer sur ENTRER pour continuer"
        read -r
    fi
}

function verifyInstagramDimensions {
    if  [[ "$WIDTH" -eq "1080" ]] && [[ "$HEIGHT" -eq "1350" ]] ; then
        echoGreen "L'image $(basename "$entry") est valide"
        VALIDINSTAGRAM=true
    else
        echoRed "ERREUR ! L'image $(basename "$entry") n'est pas valide"
        echoRed "Dimension de l'image : "$WIDTH"x"$HEIGHT""
        echoRed "Requis : 1080x1350"
        echolightbluebackground "Appuyer sur ENTRER pour continuer"
        read -r
        WRONGDIMENSIONS=$((WRONGDIMENSIONS + 1))
    fi
}

function verifyTutoDimensions {
    if  [[ "$WIDTH" -eq "750" ]] && [[ "$HEIGHT" -eq "413" ]] ; then
        echoGreen "L'image $(basename "$entry") est valide"
        VALIDTUTO=true
    else
        echoRed "ERREUR ! L'image $(basename "$entry") n'est pas valide"
        echoRed "Dimension de l'image : "$WIDTH"x"$HEIGHT""
        echoRed "Requis : 750x413"
        echolightbluebackground "Appuyer sur ENTRER pour continuer"
        read -r
    fi
}

function verifyTutoFolder {
    echo "Vérification de la présence des dossiers CULTURA.COM, HD ET INSTAGRAM"
    if [ -d "$PWD/HD" ] ; then
        echoGreen "Le dossier HD est présent"
    else
        echoRed "Le dossier HD est absent"
        echolightbluebackground "Appuyer sur entrer pour quitter"
        read -r
        exit
    fi
    if [ -d "$PWD/INSTAGRAM" ] ; then
        echoGreen "Le dossier INSTAGRAM est présent"
    else
        echoRed "Le dossier INSTAGRAM est absent"
        echolightbluebackground "Appuyer sur entrer pour quitter"
        read -r
        exit
    fi
        if [ -d "$PWD/CULTURA.COM" ] ; then
        echoGreen "Le dossier CULTURA.COM est présent"
    else
        echoRed "Le dossier CULTURA.COM est absent"
        echolightbluebackground "Appuyer sur entrer pour quitter"
        read -r
        exit
    fi
}

function verifyTutoCulturaFolderContent {
    currentFolder=$PWD
    echo "Dossier ouvert : $currentFolder"
    WRONGDIMENSIONS=0
    for entry in "$currentFolder"/*
    do
        if [[ $entry == *.jpg ]] || [[ $entry == *.png ]] || [[ $entry == *.jpeg ]] || [[ $entry == *.tiff ]]  ; then
            name=$(basename "$entry")
            name=$(echo "$name" | rev | cut -d '-' -f1 | rev)
            name=$(echo "$name" | cut -d '.' -f1)
            else
            echoRed "ERREUR ! Le fichier "$(basename "$entry")" n'est pas une image"
            echolightbluebackground "Appuyer sur ENTRER pour continuer"
            read -r
        fi
        HEIGHT=0
        WIDTH=0
        
        if [ $name == "header" ] ; then
            getImageDimensions
            verifyHeaderDimensions
       else 
            getImageDimensions
            verifyCultura.comDimensions
        fi
    done
    if [ $WRONGDIMENSIONS -eq 0 ] ; then
        echoGreen "Le dossier CULTURA.COM est valide"
        echolightbluebackground "Appuyer sur ENTRER pour continuer"
        read -r
    else
        echoRed "Le dossier CULTURA.COM n'est pas valide"
        echoRed "Il y a $WRONGDIMENSIONS images invalides"
        echolightbluebackground "Appuyer sur ENTRER pour continuer"
        read -r
        INVALIDFOLDER=$((INVALIDFOLDER + 1))
    fi

}

function verifyCultura.comDimensions {
    if  [[ "$WIDTH" -eq "750" ]] && [[ "$HEIGHT" -eq "413" ]] ; then
        echoGreen "L'image $(basename "$entry") est valide"
    else
        echoRed "ERREUR ! L'image $(basename "$entry") n'est pas valide"
        echoRed "Dimension de l'image : "$WIDTH"x"$HEIGHT""
        echoRed "Requis : 750x413"
        echolightbluebackground "Appuyer sur ENTRER pour continuer"
        read -r
        WRONGDIMENSIONS=$((WRONGDIMENSIONS + 1))
    fi
}

function verifyTutoHDFolderContent {
    currentFolder=$PWD
    WRONGDIMENSIONS=0
    for entry in "$currentFolder"/*
    do
        if [[ $entry == *.jpg ]] || [[ $entry == *.png ]] || [[ $entry == *.jpeg ]] || [[ $entry == *.tiff ]]  ; then
            name=$(basename "$entry")
            name=$(echo "$name" | rev | cut -d '-' -f1 | rev)
            name=$(echo "$name" | cut -d '.' -f1)
            else
            echoRed "ERREUR ! Le fichier "$(basename "$entry")" n'est pas une image"
            echolightbluebackground "Appuyer sur ENTRER pour continuer"
            read -r
        fi
        HEIGHT=0
        WIDTH=0
        
        getImageDimensions
        verifyHDDimensions
    done
    if [ $WRONGDIMENSIONS -eq 0 ] ; then
        echoGreen "Le dossier HD est valide"
        echolightbluebackground "Appuyer sur ENTRER pour continuer"
        read -r
    else
        echoRed "Le dossier HD n'est pas valide"
        echoRed "Il y a $WRONGDIMENSIONS images invalides"
        echolightbluebackground "Appuyer sur ENTRER pour continuer"
        read -r
        INVALIDFOLDER=$((INVALIDFOLDER + 1))

    fi
}

function verifyHDDimensions {
    if  [[ "$WIDTH" -eq "5723" ]] && [[ "$HEIGHT" -eq "3167" ]] ; then
        echoGreen "L'image $(basename "$entry") est valide"
    else
        echoRed "ERREUR ! L'image $(basename "$entry") n'est pas valide"
        echoRed "Dimension de l'image : "$WIDTH"x"$HEIGHT""
        echoRed "Requis : 5723x3167"
        echolightbluebackground "Appuyer sur ENTRER pour continuer"
        read -r
        WRONGDIMENSIONS=$((WRONGDIMENSIONS + 1))
    fi
}

function verifyTutoHDFolderContent {
    currentFolder=$PWD
    WRONGDIMENSIONS=0
    for entry in "$currentFolder"/*
    do
        if [[ $entry == *.jpg ]] || [[ $entry == *.png ]] || [[ $entry == *.jpeg ]] || [[ $entry == *.tiff ]]  ; then
            name=$(basename "$entry")
            name=$(echo "$name" | rev | cut -d '-' -f1 | rev)
            name=$(echo "$name" | cut -d '.' -f1)
            else
            echoRed "ERREUR ! Le fichier "$(basename "$entry")" n'est pas une image"
            echolightbluebackground "Appuyer sur ENTRER pour continuer"
            read -r
        fi
        HEIGHT=0
        WIDTH=0
        
        getImageDimensions
        verifyHDDimensions
    done
    if [ $WRONGDIMENSIONS -eq 0 ] ; then
        echoGreen "Le dossier HD est valide"
        echolightbluebackground "Appuyer sur ENTRER pour continuer"
    else
        echoRed "Le dossier HD n'est pas valide"
        echoRed "Il y a $WRONGDIMENSIONS images invalides"
        echolightbluebackground "Appuyer sur ENTRER pour continuer"
        read -r
        INVALIDFOLDER=$((INVALIDFOLDER + 1))
    fi
}

function verifyTutoInstagramFolderContent {
    currentFolder=$PWD
    WRONGDIMENSIONS=0
    for entry in "$currentFolder"/*
    do
        if [[ $entry == *.jpg ]] || [[ $entry == *.png ]] || [[ $entry == *.jpeg ]] || [[ $entry == *.tiff ]]  ; then
            name=$(basename "$entry")
            name=$(echo "$name" | rev | cut -d '-' -f1 | rev)
            name=$(echo "$name" | cut -d '.' -f1)
            else
            echoRed "ERREUR ! Le fichier "$(basename "$entry")" n'est pas une image"
            echolightbluebackground "Appuyer sur ENTRER pour continuer"
            read -r
        fi
        HEIGHT=0
        WIDTH=0
        
        getImageDimensions
        verifyInstagramDimensions
    done
    if [ $WRONGDIMENSIONS -eq 0 ] ; then
        echoGreen "Le dossier INSTAGRAM est valide"
        echolightbluebackground "Appuyer sur ENTRER pour continuer"
        read -r
    else
        echoRed "Le dossier INSTAGRAM n'est pas valide"
        echoRed "Il y a $WRONGDIMENSIONS images invalides"
        echolightbluebackground "Appuyer sur ENTRER pour continuer"
        read -r
        INVALIDFOLDER=$((INVALIDFOLDER + 1))
    fi
}

function main {
    clear  ;
    askForFolder ;
    INVALIDFOLDER=0
    checkForRequiredFolders ;
    cd "$FOLDER/PHOTOS AMBIANCE" ;
    verifyAmbianceFolder ;
    cd "$FOLDER/PHOTOS AMBIANCE/HD" ;
    verifyAmbianceHDFolderContent ;
    cd "$FOLDER/PHOTOS AMBIANCE/WEB" ;
    verifyAmbianceWEBFolderContent ;
    cd "$FOLDER/PHOTOS TUTO" ;
    verifyTutoFolder ;
    cd "$FOLDER/PHOTOS TUTO/CULTURA.COM" ;
    verifyTutoCulturaFolderContent ;
    cd "$FOLDER/PHOTOS TUTO/HD" ;
    verifyTutoHDFolderContent ;
    cd "$FOLDER/PHOTOS TUTO/INSTAGRAM" ;
    verifyTutoInstagramFolderContent ;
    if [ "$INVALIDFOLDER" -eq 0 ] ; then
        echoGreen "Toutes les dossiers sont valides"
    else
        echoRed "Il y a $INVALIDFOLDER dossiers invalides"
    fi
    echolightbluebackground "Appuyer sur ENTRER pour quitter"
    read -r
    clear
}

main ;
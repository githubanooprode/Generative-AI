function [currentStep,priority] = resetPriorityForBadPixels(settings,currentStep,priority)

%RESET PRIORITY FOR BAD PIXELS TO ZERO
if settings.localUpdate
    achol=currentStep.numBad;
    myCount=0;
    tmp_BPB=zeros(size(currentStep.BadPixelBank));
    if achol ~=0
        for loopMe = 1:achol
            %fprintf('Step %d:: Local Version, Bad Pixels, number  %d of %d) %d,%d\n',currentStep.step_number,loopMe,achol,BadPixelBank(loopMe,1),BadPixelBank(loopMe,2))
            if currentStep.targetContour3Color(currentStep.BadPixelBank(loopMe,1),currentStep.BadPixelBank(loopMe,2),1)
                myCount=myCount + 1;
                tmp_BPB(myCount,:)=[currentStep.BadPixelBank(loopMe,1),currentStep.BadPixelBank(loopMe,2)];
            end
            priority(currentStep.BadPixelBank(loopMe,1),currentStep.BadPixelBank(loopMe,2))=0;
        end
        currentStep.BadPixelBank=tmp_BPB;
        currentStep.numBad=myCount;
    end
else
    achol=size(currentStep.BadPixelBank,1);
    tmp_BPB=[];
    if achol ~=0
        for loopMe = 1:achol
            %fprintf('Step %d:: Global Version, Bad Pixels, number  %d of %d) %d,%d\n',currentStep.step_number,loopMe,achol,BadPixelBank(loopMe,1),BadPixelBank(loopMe,2))
            if currentStep.targetContour3Color(currentStep.BadPixelBank(loopMe,1),currentStep.BadPixelBank(loopMe,2),1)
                tmp_BPB=[tmp_BPB; currentStep.BadPixelBank(loopMe,1),currentStep.BadPixelBank(loopMe,2)];
            end
            priority(currentStep.BadPixelBank(loopMe,1),currentStep.BadPixelBank(loopMe,2))=0;
        end
        currentStep.BadPixelBank=tmp_BPB;
    end
end

